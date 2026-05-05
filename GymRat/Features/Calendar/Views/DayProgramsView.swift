import SwiftUI

struct DayProgramsView: View {
    private let selectedDate: Date
    private let programViewModel: ProgramViewModel
    @Environment(ThemeStore.self) private var themeStore
    let onAddProgramTap: () -> Void
    @State private var viewModel: DayProgramsViewModel

    init(
        selectedDate: Date,
        programViewModel: ProgramViewModel,
        onAddProgramTap: @escaping () -> Void
    ) {
        self.selectedDate = selectedDate
        self.programViewModel = programViewModel
        self.onAddProgramTap = onAddProgramTap
        _viewModel = State(initialValue: DayProgramsViewModel(
            selectedDate: selectedDate,
            programViewModel: programViewModel
        ))
    }

    // MARK: - Body
    var body: some View {
        DayProgramsList(
            selectedDate: viewModel.selectedDate,
            dayPrograms: dayProgramsBinding,
            draggingProgram: draggingProgramBinding,
            accentColor: themeStore.accentColor,
            onEdit: { viewModel.edit($0) },
            onAddProgramTap: onAddProgramTap,
            onReorder: viewModel.applyReorder
        )
        .sheet(item: editingProgramBinding) { program in
            ProgramEditorView(
                viewModel: ProgramEditorFactory.make(
                    mode: .edit,
                    program: program,
                    programViewModel: programViewModel
                )
            )
            .environment(themeStore)
            .accentColor(themeStore.accentColor)
        }
        .onChange(of: selectedDate) { _, _ in
            viewModel.updateSelectedDate(selectedDate)
        }
        .onChange(of: programViewModel.customProgramIds) { _, _ in
            viewModel.reload()
        }
    }

    // MARK: - Helpers
    private var dayProgramsBinding: Binding<[Program]> {
        Binding(
            get: { viewModel.dayPrograms },
            set: { viewModel.setPrograms($0) }
        )
    }

    private var draggingProgramBinding: Binding<Program?> {
        Binding(
            get: { viewModel.draggingProgram },
            set: { viewModel.setDraggingProgram($0) }
        )
    }

    private var editingProgramBinding: Binding<Program?> {
        Binding(
            get: { viewModel.editingProgram },
            set: { viewModel.edit($0) }
        )
    }
}
