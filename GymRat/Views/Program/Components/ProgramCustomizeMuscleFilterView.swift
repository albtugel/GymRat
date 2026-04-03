import SwiftUI

struct ProgramCustomizeMuscleFilterView: View {
    private let viewModel: ProgramCustomizeViewModel

    init(viewModel: ProgramCustomizeViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                    let isSelected = viewModel.isMuscleSelected(muscle)
                    Button {
                        withAnimation {
                            viewModel.toggleMuscle(muscle)
                        }
                    } label: {
                        Text(MuscleGroupDisplay.localizedLabel(for: muscle))
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.accentColor : Color(.systemGray5))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
}
