import SwiftUI

struct ProgramForSelectedDayListView: View {
    private let selectedDate: Date
    @Binding private var dayPrograms: [ProgramModel]
    @Binding private var draggingProgram: ProgramModel?
    private let accentColor: Color
    private let onEdit: (ProgramModel) -> Void
    private let onAddProgramTap: () -> Void
    private let onReorder: ([ProgramModel]) -> Void

    init(
        selectedDate: Date,
        dayPrograms: Binding<[ProgramModel]>,
        draggingProgram: Binding<ProgramModel?>,
        accentColor: Color,
        onEdit: @escaping (ProgramModel) -> Void,
        onAddProgramTap: @escaping () -> Void,
        onReorder: @escaping ([ProgramModel]) -> Void
    ) {
        self.selectedDate = selectedDate
        self._dayPrograms = dayPrograms
        self._draggingProgram = draggingProgram
        self.accentColor = accentColor
        self.onEdit = onEdit
        self.onAddProgramTap = onAddProgramTap
        self.onReorder = onReorder
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ProgramForSelectedDayProgramsList(
                    selectedDate: selectedDate,
                    dayPrograms: $dayPrograms,
                    draggingProgram: $draggingProgram,
                    onEdit: onEdit,
                    onReorder: onReorder
                )

                ProgramForSelectedDayAddButton(
                    accentColor: accentColor,
                    onAddProgramTap: onAddProgramTap
                )
            }
            .padding(.vertical, dayPrograms.isEmpty ? 10 : 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .overlay(
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(accentColor)
                        .frame(height: 2)
                    Spacer()
                    Rectangle()
                        .fill(accentColor)
                        .frame(height: 2)
                }
            )
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
    }
}
