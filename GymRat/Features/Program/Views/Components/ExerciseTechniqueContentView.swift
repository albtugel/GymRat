import SwiftUI

struct ExerciseTechniqueContentView: View {
    private let imageURLs: [URL]
    private let placeholderSystemName: String
    private let musclesTitle: String
    private let muscleLabels: [String]

    init(
        imageURLs: [URL],
        placeholderSystemName: String,
        musclesTitle: String,
        muscleLabels: [String]
    ) {
        self.imageURLs = imageURLs
        self.placeholderSystemName = placeholderSystemName
        self.musclesTitle = musclesTitle
        self.muscleLabels = muscleLabels
    }

    var body: some View {
        VStack(spacing: 20) {
            ExerciseTechniqueImagesSectionView(
                imageURLs: imageURLs,
                placeholderSystemName: placeholderSystemName
            )

            ExerciseTechniqueMusclesSectionView(
                title: musclesTitle,
                muscleLabels: muscleLabels
            )
        }
        .padding(.vertical)
    }
}
