import Foundation
import Observation

@Observable
@MainActor
final class ExerciseDetailsViewModel {
    private let seed: ExerciseRepo.ExerciseSeed

    let title: String
    let imageURLs: [URL]
    let muscleLabels: [String]
    let musclesTitle: String
    let placeholderSystemName: String

    init(seed: ExerciseRepo.ExerciseSeed) {
        self.seed = seed
        self.title = seed.name
        self.musclesTitle = String(localized: "muscles_section")
        self.placeholderSystemName = "figure.run"
        
        self.imageURLs = seed.imageURLs
        
        self.muscleLabels = seed.muscles.map { MuscleText.localizedLabel(for: $0) }
    }
}
