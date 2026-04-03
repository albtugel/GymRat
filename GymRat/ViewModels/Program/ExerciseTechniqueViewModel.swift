import Foundation
import Observation

@Observable
@MainActor
final class ExerciseTechniqueViewModel {
    private let seed: ExerciseStore.ExerciseSeed

    let title: String
    let imageURLs: [URL]
    let muscleLabels: [String]
    let musclesTitle: String
    let placeholderSystemName: String

    init(seed: ExerciseStore.ExerciseSeed) {
        self.seed = seed
        self.title = seed.name
        self.musclesTitle = String(localized: "muscles_section")
        self.placeholderSystemName = "figure.run"
        self.imageURLs = ExerciseTechniqueViewModel.makeImageURLs(for: seed)
        self.muscleLabels = seed.muscles.map { MuscleGroupDisplay.localizedLabel(for: $0) }
    }

    private static func makeImageURLs(for seed: ExerciseStore.ExerciseSeed) -> [URL] {
        guard let key = seed.exerciseDBKey else { return [] }
        let base = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises"
        return [0, 1].compactMap { URL(string: "\(base)/\(key)/\($0).jpg") }
    }
}
