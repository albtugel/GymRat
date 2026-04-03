import SwiftUI

struct ProgramForSelectedDayView: View {
    private let selectedDate: Date
    private let programViewModel: ProgramViewModel
    @Environment(ThemeManager.self) private var themeManager
    let onAddProgramTap: () -> Void
    @State private var viewModel: ProgramForSelectedDayViewModel

    init(
        selectedDate: Date,
        programViewModel: ProgramViewModel,
        onAddProgramTap: @escaping () -> Void
    ) {
        self.selectedDate = selectedDate
        self.programViewModel = programViewModel
        self.onAddProgramTap = onAddProgramTap
        _viewModel = State(initialValue: ProgramForSelectedDayViewModel(
            selectedDate: selectedDate,
            programViewModel: programViewModel
        ))
    }

    // MARK: - Body
    var body: some View {
        ProgramForSelectedDayListView(
            selectedDate: viewModel.selectedDate,
            dayPrograms: dayProgramsBinding,
            draggingProgram: draggingProgramBinding,
            accentColor: themeManager.accentColor,
            onEdit: { viewModel.setEditingProgram($0) },
            onAddProgramTap: onAddProgramTap,
            onReorder: viewModel.applyReorder
        )
        .sheet(item: editingProgramBinding) { program in
            ProgramCustomizeSheetView(
                viewModel: ProgramCustomizeViewModelFactory.make(
                    mode: .edit,
                    program: program,
                    programViewModel: programViewModel
                )
            )
            .environment(themeManager)
            .accentColor(themeManager.accentColor)
        }
        .onChange(of: selectedDate) { _, _ in
            viewModel.updateSelectedDate(selectedDate)
        }
        .onChange(of: programViewModel.customProgramIds) { _, _ in
            viewModel.updatePrograms()
        }
    }

    // MARK: - Helpers
    private var dayProgramsBinding: Binding<[ProgramModel]> {
        Binding(
            get: { viewModel.dayPrograms },
            set: { viewModel.updateDayPrograms($0) }
        )
    }

    private var draggingProgramBinding: Binding<ProgramModel?> {
        Binding(
            get: { viewModel.draggingProgram },
            set: { viewModel.setDraggingProgram($0) }
        )
    }

    private var editingProgramBinding: Binding<ProgramModel?> {
        Binding(
            get: { viewModel.editingProgram },
            set: { viewModel.setEditingProgram($0) }
        )
    }
}
