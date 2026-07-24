import SwiftUI

struct ExerciseDetailsContent: View {
    private let imageURLs: [URL]
    private let placeholderSystemName: String
    private let musclesTitle: String
    private let muscleLabels: [String]
    private let instructionsTitle: String
    private let instructions: [String]

    init(
        imageURLs: [URL],
        placeholderSystemName: String,
        musclesTitle: String,
        muscleLabels: [String],
        instructionsTitle: String,
        instructions: [String]
    ) {
        self.imageURLs = imageURLs
        self.placeholderSystemName = placeholderSystemName
        self.musclesTitle = musclesTitle
        self.muscleLabels = muscleLabels
        self.instructionsTitle = instructionsTitle
        self.instructions = instructions
    }

    var body: some View {
        VStack(spacing: 20) {
            ExerciseImagesView(
                imageURLs: imageURLs,
                placeholderSystemName: placeholderSystemName
            )

            ExerciseMusclesView(
                title: musclesTitle,
                muscleLabels: muscleLabels
            )

            if !instructions.isEmpty {
                ExerciseInstructionsView(
                    title: instructionsTitle,
                    steps: instructions
                )
            }
        }
        .padding(.vertical)
    }
}
