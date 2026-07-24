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

    /// The catalog prefixes each step with a `Step:N` marker; strip it so the UI shows clean text.
    private static func instructionSteps(from seed: ExerciseRepo.ExerciseSeed) -> [String] {
        (seed.remoteExercise?.instructions ?? []).compactMap { raw in
            let cleaned = raw
                .replacingOccurrences(
                    of: #"^\s*Step\s*:?\s*\d+\s*[:.)-]?\s*"#,
                    with: "",
                    options: [.regularExpression, .caseInsensitive]
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.isEmpty ? nil : cleaned
        }
    }
}
