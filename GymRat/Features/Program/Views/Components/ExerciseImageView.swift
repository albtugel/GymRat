import SwiftUI
import Kingfisher

struct ExerciseImageView: View {
    private let url: URL
    private let exerciseName: String
    @State private var didFail = false
    /// Changing the view identity is what makes Kingfisher issue a fresh request after a failure.
    @State private var attempt = 0

    init(url: URL, exerciseName: String) {
        self.url = url
        self.exerciseName = exerciseName
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))

            if didFail {
                Button {
                    didFail = false
                    attempt += 1
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 32))
                        Text("details_image_retry_button")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("exerciseImageRetryButton")
            } else {
                KFAnimatedImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .cancelOnDisappear(true)
                    .onFailure { _ in
                        didFail = true
                    }
                    .configure { imageView in
                        imageView.autoPlayAnimatedImage = true
                        imageView.contentMode = .scaleAspectFit
                    }
                    .id(attempt)
                    .accessibilityElement()
                    .accessibilityLabel(
                        String(format: String(localized: "details_image_accessibility_format"), exerciseName)
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: url) {
            didFail = false
            attempt = 0
        }
    }
}
