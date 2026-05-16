import SwiftUI
import Kingfisher

struct ExerciseImageView: View {
    private let url: URL
    @State private var didFail = false

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))

            if didFail {
                Image(systemName: "figure.run")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
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
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: url) {
            didFail = false
        }
    }
}
