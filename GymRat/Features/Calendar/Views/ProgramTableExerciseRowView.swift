import SwiftUI
import UniformTypeIdentifiers

struct ProgramTableExerciseRowView: View {
    @State private var viewModel: ProgramTableExerciseRowViewModel
    let program: ProgramModel
    let selectedDate: Date
    @Binding var draggingExercise: ProgramExercise?
    @FocusState.Binding var focusedField: ProgramTableFocusField?

    @Environment(ThemeManager.self) private var themeManager
    @Environment(ProgramViewModel.self) private var programViewModel

    init(
        viewModel: ProgramTableExerciseRowViewModel,
        program: ProgramModel,
        selectedDate: Date,
        draggingExercise: Binding<ProgramExercise?>,
        focusedField: FocusState<ProgramTableFocusField?>.Binding
    ) {
        self.program = program
        self.selectedDate = selectedDate
        self._viewModel = State(initialValue: viewModel)
        self._draggingExercise = draggingExercise
        self._focusedField = focusedField
    }

    var body: some View {
        ProgramTableExerciseRowContentView(
            viewModel: viewModel,
            focusedField: $focusedField,
            accentColor: themeManager.accentColor
        )
            .onAppear { Task { await viewModel.loadLog() } }
            .onChange(of: selectedDate) { _, newValue in
                Task { await viewModel.updateSelectedDate(newValue) }
            }
            .onReceive(NotificationCenter.default.publisher(for: .saveExerciseLogs)) { _ in
                Task { await viewModel.handleDisappear() }
            }
            .onChange(of: focusedField) { _, newValue in
                Task { await viewModel.handleFocusChange(newValue) }
            }
            .onDisappear {
                Task { await viewModel.handleDisappear() }
            }
            .onDrag {
                draggingExercise = viewModel.programExercise
                viewModel.handleDragStart()
                return NSItemProvider(item: Data() as NSData, typeIdentifier: UTType.data.identifier)
            }
            .onDrop(
                of: [UTType.data],
                delegate: ProgramExerciseDropDelegate(
                    item: viewModel.programExercise,
                    program: program,
                    dragging: $draggingExercise,
                    onReorder: { source, destination in
                        Task { await programViewModel.reorderExercises(in: program, from: source, to: destination) }
                    }
                )
            )
    }
}
