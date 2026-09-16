import SwiftUI

struct DayProgramsView: View {
    private let selectedDate: Date
    private let programViewModel: ProgramViewModel
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.viewModelFactory) private var viewModelFactory
    let onAddProgramTap: () -> Void
    @State private var viewModel: DayProgramsViewModel

    /// `viewModel` seeds `@State`: SwiftUI keeps the first instance and ignores the ones the parent
    /// builds on later renders, so the parent may create it inline.
    init(
        viewModel: DayProgramsViewModel,
        selectedDate: Date,
        programViewModel: ProgramViewModel,
        onAddProgramTap: @escaping () -> Void
    ) {
        self.selectedDate = selectedDate
        self.programViewModel = programViewModel
        self.onAddProgramTap = onAddProgramTap
        _viewModel = State(initialValue: viewModel)
    }


    var body: some View {
        DayProgramsList(
            selectedDate: viewModel.selectedDate,
            dayPrograms: dayProgramsBinding,
            draggingProgram: draggingProgramBinding,
            accentColor: themeStore.accentColor,
            onEdit: { viewModel.edit($0) },
            onDelete: { viewModel.delete($0) },
            onAddProgramTap: onAddProgramTap,
            onReorder: viewModel.applyReorder
        )
        .sheet(item: editingProgramBinding) { program in
            ProgramEditorView(
                viewModel: viewModelFactory.makeProgramEditorViewModel(
                    mode: .edit,
                    program: program,
                    programViewModel: programViewModel
                )
            )
            .environment(themeStore)
            .accentColor(themeStore.accentColor)
        }
        .task {
            viewModel.prefetchImages()
        }
        .onChange(of: selectedDate) { _, _ in
            viewModel.updateSelectedDate(selectedDate)
        }
        .onChange(of: programViewModel.customProgramIds) { _, _ in
            viewModel.reload()
        }
    }


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
