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
        
        self.imageURLs = seed.imageURLs
        
        self.muscleLabels = seed.muscles.map { MuscleGroupDisplay.localizedLabel(for: $0) }
    }
}
