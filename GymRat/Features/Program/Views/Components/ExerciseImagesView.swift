import SwiftUI

struct ExerciseImagesView: View {
    private let imageURLs: [URL]
    private let placeholderSystemName: String
    private let exerciseName: String

    init(imageURLs: [URL], placeholderSystemName: String, exerciseName: String) {
        self.imageURLs = imageURLs
        self.placeholderSystemName = placeholderSystemName
        self.exerciseName = exerciseName
    }

    var body: some View {
        Group {
            if imageURLs.isEmpty {
                ExercisePlaceholderView(systemName: placeholderSystemName)
            } else {
                VStack(spacing: 12) {
                    ForEach(imageURLs, id: \.self) { url in
                        ExerciseImageView(url: url, exerciseName: exerciseName)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
