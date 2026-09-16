import SwiftUI

struct DayProgramsList: View {
    private let selectedDate: Date
    @Binding private var dayPrograms: [ProgramSnapshot]
    @Binding private var draggingProgram: ProgramSnapshot?
    private let accentColor: Color
    private let onEdit: (ProgramSnapshot) -> Void
    private let onDelete: (ProgramSnapshot) -> Void
    private let onAddProgramTap: () -> Void
    private let onReorder: ([ProgramSnapshot]) -> Void

    init(
        selectedDate: Date,
        dayPrograms: Binding<[ProgramSnapshot]>,
        draggingProgram: Binding<ProgramSnapshot?>,
        accentColor: Color,
        onEdit: @escaping (ProgramSnapshot) -> Void,
        onDelete: @escaping (ProgramSnapshot) -> Void,
        onAddProgramTap: @escaping () -> Void,
        onReorder: @escaping ([ProgramSnapshot]) -> Void
    ) {
        self.selectedDate = selectedDate
        self._dayPrograms = dayPrograms
        self._draggingProgram = draggingProgram
        self.accentColor = accentColor
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onAddProgramTap = onAddProgramTap
        self.onReorder = onReorder
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ProgramsList(
                    selectedDate: selectedDate,
                    dayPrograms: $dayPrograms,
                    draggingProgram: $draggingProgram,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onReorder: onReorder
                )

                AddProgramButton(
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
