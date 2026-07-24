import SwiftUI

struct ProgramHeader: View {
    let name: String
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    @State private var isShowingActions = false
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.headline)
                .bold()
                .lineLimit(1)
                .padding(.top, 4)

            Spacer()

            if onEdit != nil || onDelete != nil {
                Button {
                    isShowingActions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .frame(width: 28, height: 28)
                }
                .font(.headline.weight(.semibold))
                .foregroundColor(.accentColor)
                .buttonStyle(.plain)
                .accessibilityLabel("Program actions")
                .accessibilityIdentifier("programActionsMenuButton")
                .popover(isPresented: $isShowingActions, arrowEdge: .trailing) {
                    actionsMenu
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .alert("Delete \"\(name)\"?", isPresented: $isShowingDeleteConfirmation) {
            Button("Delete", role: .destructive) { onDelete?() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the program and its schedule from all days.")
        }
    }

    private var actionsMenu: some View {
        VStack(spacing: 0) {
            if let onEdit {
                Button {
                    isShowingActions = false
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.headline.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .accessibilityLabel("Edit program")
                .accessibilityIdentifier("programEditButton")
            }

            if onEdit != nil, onDelete != nil {
                Divider()
            }

            if onDelete != nil {
                Button {
                    isShowingActions = false
                    isShowingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.headline.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .accessibilityLabel("Delete program")
                .accessibilityIdentifier("programDeleteButton")
            }
        }
        .padding(6)
        .fixedSize()
    }
}
