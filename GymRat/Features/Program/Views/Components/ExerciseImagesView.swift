import SwiftUI

struct ExerciseImagesView: View {
    private let imageURLs: [URL]
    private let placeholderSystemName: String

    init(imageURLs: [URL], placeholderSystemName: String) {
        self.imageURLs = imageURLs
        self.placeholderSystemName = placeholderSystemName
    }

    var body: some View {
        Group {
            if imageURLs.isEmpty {
                ExercisePlaceholderView(systemName: placeholderSystemName)
            } else {
                VStack(spacing: 12) {
                    ForEach(imageURLs.indices, id: \.self) { index in
                        ExerciseImageView(url: imageURLs[index])
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
