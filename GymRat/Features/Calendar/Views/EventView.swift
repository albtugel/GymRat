import SwiftUI

struct EventView: View {
    let title: String
    let backgroundColor: Color

    var body: some View {
        Text(title)
            .font(.caption2)
            .padding(4)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}
