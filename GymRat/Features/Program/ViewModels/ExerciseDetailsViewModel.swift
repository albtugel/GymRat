import Foundation
import Observation

@Observable
@MainActor
final class ExerciseDetailsViewModel {
    private let seed: ExerciseRepo.ExerciseSeed

    let title: String
    private(set) var imageURLs: [URL]
    private(set) var muscleLabels: [String]
    let musclesTitle: String
    let placeholderSystemName: String

    init(seed: ExerciseRepo.ExerciseSeed) {
        self.seed = seed
        self.title = seed.name
        self.musclesTitle = String(localized: "muscles_section")
        self.placeholderSystemName = "figure.run"

        self.imageURLs = [seed.gifURL].compactMap { $0 }

        self.muscleLabels = seed.muscles.map { MuscleText.localizedLabel(for: $0) }
    }

    func loadLatestDetails() async {
        if let latestSeed = await ExerciseRepo.shared.getExerciseSeedResolvingRemote(named: seed.name) {
            apply(latestSeed)
        }
    }

    private func apply(_ seed: ExerciseRepo.ExerciseSeed) {
        imageURLs = [seed.gifURL].compactMap { $0 }
        muscleLabels = seed.muscles.map { MuscleText.localizedLabel(for: $0) }
    }
}
