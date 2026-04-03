import SwiftUI

struct ExerciseTechniqueAsyncImageView: View {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .overlay(ProgressView())
        }
    }
}
