import SwiftUI

struct ProgramTableTitleCard: View {
    let name: String
    let onEdit: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.headline)
                .bold()
                .lineLimit(1)
                .padding(.top, 4)

            Spacer()

            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.accentColor)
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
