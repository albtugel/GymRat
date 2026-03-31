import SwiftUI

struct ProgramTableTitleCard: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.headline)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }
}
