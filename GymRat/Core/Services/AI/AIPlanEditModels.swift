import Foundation

struct AIPlanEditResponse: Codable, Equatable {
    struct Exercise: Codable, Equatable {
        let name: String
        let sets: Int
        let reps: Int
    }

    let programName: String?
    let exercises: [Exercise]

    enum CodingKeys: String, CodingKey {
        case programName = "program_name"
        case exercises
    }
}

struct AIPlanEditPreview: Equatable {
    enum ChangeKind: String, Equatable {
        case added
        case changed
        case unchanged
        case custom
    }

    struct Exercise: Identifiable, Equatable {
        let id = UUID()
        let requestedName: String
        let resolvedName: String
        let sets: Int
        let reps: Int
        let isUnknown: Bool
        let changeKind: ChangeKind
    }

    let programName: String?
    let exercises: [Exercise]
    let removedExerciseNames: [String]

    var hasUnknownExercises: Bool {
        exercises.contains(where: \.isUnknown)
    }

    var hasRemovedExercises: Bool {
        !removedExerciseNames.isEmpty
    }
}

enum AIPlanEditError: LocalizedError, Equatable {
    case missingAPIKey
    case emptyPrompt
    case invalidJSON
    case emptyPlan

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return String(localized: "ai_missing_api_key_error")
        case .emptyPrompt:
            return String(localized: "ai_empty_prompt_error")
        case .invalidJSON:
            return String(localized: "ai_invalid_json_error")
        case .emptyPlan:
            return String(localized: "ai_empty_plan_error")
        }
    }
}

enum AIPlanEditParser {
    static func decode(_ content: String) throws -> AIPlanEditResponse {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else {
            throw AIPlanEditError.invalidJSON
        }
        do {
            return try JSONDecoder().decode(AIPlanEditResponse.self, from: data)
        } catch {
            guard
                let start = trimmed.firstIndex(of: "{"),
                let end = trimmed.lastIndex(of: "}"),
                start < end
            else {
                throw AIPlanEditError.invalidJSON
            }
            let object = String(trimmed[start...end])
            guard let objectData = object.data(using: .utf8) else {
                throw AIPlanEditError.invalidJSON
            }
            do {
                return try JSONDecoder().decode(AIPlanEditResponse.self, from: objectData)
            } catch {
                throw AIPlanEditError.invalidJSON
            }
        }
    }
}

enum AIPlanEditPromptBuilder {
    static func messages(
        prompt: String,
        programName: String,
        programType: ProgramType,
        selectedExercises: [WorkoutExercise],
        availableExerciseNames: [String]
    ) -> [MistralChatMessage] {
        let current = selectedExercises
            .map { "\($0.exercise.name): sets=\($0.sets), reps=\($0.reps)" }
            .joined(separator: "\n")
        let available = availableExerciseNames.joined(separator: ", ")
        let system = """
        You edit gym workout plans. Return only a valid JSON object with this exact shape:
        {"program_name":"optional new name","exercises":[{"name":"Exercise name","sets":3,"reps":10}]}
        Use existing exercise names when possible. Sets must be 1 to 10. Reps must be 0 or greater. Do not include markdown.
        """
        let user = """
        Program name: \(programName)
        Program type: \(programType.rawValue)

        Current exercises:
        \(current.isEmpty ? "None" : current)

        Available exercises:
        \(available)

        User request:
        \(prompt)
        """
        return [
            MistralChatMessage(role: "system", content: system),
            MistralChatMessage(role: "user", content: user)
        ]
    }
}

@MainActor
enum AIPlanEditApplier {
    static func makePreview(
        response: AIPlanEditResponse,
        availableExercises: [Exercise],
        seedNames: [String],
        existingSelectedExercises: [WorkoutExercise]
    ) throws -> AIPlanEditPreview {
        var existingByName: [String: WorkoutExercise] = [:]
        for exercise in existingSelectedExercises {
            existingByName[normalize(exercise.exercise.name), default: exercise] = exercise
        }
        var resultNames = Set<String>()
        let items = response.exercises
            .map { item -> AIPlanEditPreview.Exercise in
                let resolved = resolveName(item.name, availableExercises: availableExercises, seedNames: seedNames)
                let resolvedName = resolved ?? item.name.trimmingCharacters(in: .whitespacesAndNewlines)
                let key = normalize(resolvedName)
                resultNames.insert(key)
                let sets = min(10, max(1, item.sets))
                let reps = max(0, item.reps)
                let existing = existingByName[key]
                let changeKind = resolveChangeKind(
                    isUnknown: resolved == nil,
                    existing: existing,
                    sets: sets,
                    reps: reps
                )
                return AIPlanEditPreview.Exercise(
                    requestedName: item.name,
                    resolvedName: resolvedName,
                    sets: sets,
                    reps: reps,
                    isUnknown: resolved == nil,
                    changeKind: changeKind
                )
            }
            .filter { !$0.resolvedName.isEmpty }
        guard !items.isEmpty else {
            throw AIPlanEditError.emptyPlan
        }
        let removed = existingSelectedExercises
            .filter { !resultNames.contains(normalize($0.exercise.name)) }
            .map { $0.exercise.name }
        let name = response.programName?.trimmingCharacters(in: .whitespacesAndNewlines)
        return AIPlanEditPreview(
            programName: name?.isEmpty == false ? name : nil,
            exercises: items,
            removedExerciseNames: removed
        )
    }

    static func apply(
        preview: AIPlanEditPreview,
        programType: ProgramType,
        existingSelectedExercises: [WorkoutExercise],
        availableExercises: [Exercise]
    ) -> (programName: String?, exercises: [WorkoutExercise], customExercises: [Exercise]) {
        var customExercises: [Exercise] = []
        var result: [WorkoutExercise] = []

        for (index, item) in preview.exercises.enumerated() {
            let exercise = resolveExercise(
                name: item.resolvedName,
                availableExercises: availableExercises,
                customExercises: customExercises
            ) ?? makeCustomExercise(name: item.resolvedName, programType: programType)

            if exercise.isCustom && !availableExercises.contains(where: { $0.id == exercise.id }) {
                customExercises.append(exercise)
            }

            let existing = existingSelectedExercises.first {
                normalize($0.exercise.name) == normalize(exercise.name)
            }
            let programExercise = existing ?? WorkoutExercise(exercise: exercise, sharedHistory: false)
            programExercise.sets = item.sets
            programExercise.reps = item.reps
            programExercise.selectionIndex = index + 1
            result.append(programExercise)
        }

        return (preview.programName, result, customExercises)
    }

    private static func makeCustomExercise(name: String, programType: ProgramType) -> Exercise {
        let category: ExerciseCategory = {
            switch programType {
            case .strength: return .strength
            case .cardio: return .cardio
            case .crossfit: return .crossfit
            }
        }()
        return Exercise(name: name, categoryRaw: category.rawValue, isCustom: true)
    }

    private static func resolveExercise(
        name: String,
        availableExercises: [Exercise],
        customExercises: [Exercise]
    ) -> Exercise? {
        (availableExercises + customExercises).first { normalize($0.name) == normalize(name) }
    }

    private static func resolveName(
        _ name: String,
        availableExercises: [Exercise],
        seedNames: [String]
    ) -> String? {
        let key = normalize(name)
        if let existing = availableExercises.first(where: { normalize($0.name) == key }) {
            return existing.name
        }
        return seedNames.first { normalize($0) == key }
    }

    private static func resolveChangeKind(
        isUnknown: Bool,
        existing: WorkoutExercise?,
        sets: Int,
        reps: Int
    ) -> AIPlanEditPreview.ChangeKind {
        if isUnknown {
            return .custom
        }
        guard let existing else {
            return .added
        }
        if existing.sets == sets && existing.reps == reps {
            return .unchanged
        }
        return .changed
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
