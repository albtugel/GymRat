import SwiftUI

struct DayProgramsList: View {
    private let selectedDate: Date
    @Binding private var dayPrograms: [Program]
    @Binding private var draggingProgram: Program?
    private let accentColor: Color
    private let onEdit: (Program) -> Void
    private let onAddProgramTap: () -> Void
    private let onReorder: ([Program]) -> Void

    init(
        selectedDate: Date,
        dayPrograms: Binding<[Program]>,
        draggingProgram: Binding<Program?>,
        accentColor: Color,
        onEdit: @escaping (Program) -> Void,
        onAddProgramTap: @escaping () -> Void,
        onReorder: @escaping ([Program]) -> Void
    ) {
        self.selectedDate = selectedDate
        self._dayPrograms = dayPrograms
        self._draggingProgram = draggingProgram
        self.accentColor = accentColor
        self.onEdit = onEdit
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
