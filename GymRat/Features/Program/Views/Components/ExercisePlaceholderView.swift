import SwiftUI

struct ExercisePlaceholderView: View {
    private let systemName: String

    init(systemName: String) {
        self.systemName = systemName
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray5))
            .frame(height: 200)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
            )
            .padding(.horizontal)
    }
}
