import SwiftUI
import UniformTypeIdentifiers

struct ExerciseRow: View {
    @State private var viewModel: ExerciseRowViewModel
    let program: Program
    let selectedDate: Date
    @Binding var draggingExercise: WorkoutExercise?
    @FocusState.Binding var focusedField: ExerciseField?

    @Environment(ThemeStore.self) private var themeStore
    @Environment(ProgramViewModel.self) private var programViewModel

    init(
        viewModel: ExerciseRowViewModel,
        program: Program,
        selectedDate: Date,
        draggingExercise: Binding<WorkoutExercise?>,
        focusedField: FocusState<ExerciseField?>.Binding
    ) {
        self.program = program
        self.selectedDate = selectedDate
        self._viewModel = State(initialValue: viewModel)
        self._draggingExercise = draggingExercise
        self._focusedField = focusedField
    }

    var body: some View {
        ExerciseLogRowRootView(
            viewModel: viewModel,
            focusedField: $focusedField,
            accentColor: themeStore.accentColor
        )
            .onAppear { Task { await viewModel.load() } }
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
                delegate: WorkoutExerciseDropDelegate(
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
