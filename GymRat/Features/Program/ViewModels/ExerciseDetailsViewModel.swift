import Foundation
import Observation

@Observable
@MainActor
final class ExerciseDetailsViewModel {
    private let seed: ExerciseRepo.ExerciseSeed

    let title: String
    private(set) var imageURLs: [URL]
    private(set) var muscleLabels: [String]
    private(set) var instructions: [String]
    let musclesTitle: String
    let instructionsTitle: String
    let placeholderSystemName: String

    init(seed: ExerciseRepo.ExerciseSeed) {
        self.seed = seed
        self.title = seed.name
        self.musclesTitle = String(localized: "muscles_section")
        self.instructionsTitle = String(localized: "instructions_section")
        self.placeholderSystemName = "figure.run"

        self.imageURLs = [seed.gifURL].compactMap { $0 }

        self.muscleLabels = seed.muscles.map { MuscleText.localizedLabel(for: $0) }
        self.instructions = Self.instructionSteps(from: seed)
    }

    func loadLatestDetails() async {
        if let latestSeed = await ExerciseRepo.shared.getExerciseSeedResolvingRemote(named: seed.name) {
            apply(latestSeed)
        }
    }

    private func apply(_ seed: ExerciseRepo.ExerciseSeed) {
        imageURLs = [seed.gifURL].compactMap { $0 }
        muscleLabels = seed.muscles.map { MuscleText.localizedLabel(for: $0) }
        instructions = Self.instructionSteps(from: seed)
    }

    /// Condenses catalog instructions for a compact details screen: strips the `Step:N` marker,
    /// drops the ubiquitous "Repeat for the desired number of repetitions." closing boilerplate,
    /// and keeps only the first clause (up to the first comma) so each step reads as a short cue.
    private static func instructionSteps(from seed: ExerciseRepo.ExerciseSeed) -> [String] {
        (seed.remoteExercise?.instructions ?? []).compactMap { raw in
            let full = raw
                .replacingOccurrences(
                    of: #"^\s*Step\s*:?\s*\d+\s*[:.)-]?\s*"#,
                    with: "",
                    options: [.regularExpression, .caseInsensitive]
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !full.lowercased().hasPrefix("repeat for the desired number of") else { return nil }

            let firstClause = full.firstIndex(of: ",").map { String(full[..<$0]) } ?? full
            let cleaned = firstClause
                .replacingOccurrences(of: #"[.;:!]+$"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return cleaned.isEmpty ? nil : cleaned
        }
    }
}
