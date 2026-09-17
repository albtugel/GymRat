import Foundation
import Observation

/// Program details (name, colour, weekdays) and saving. The exercise list lives in `picker`.
@Observable
@MainActor
final class ProgramEditorViewModel {
    private(set) var mode: ProgramEditorMode
    private(set) var program: ProgramSnapshot
    private(set) var programName: String
    private(set) var programColorHex: String
    private(set) var selectedWeekdays: Set<ProgramWeekday>
    private(set) var isSaving: Bool = false
    private(set) var showWeekdaysRequiredAlert: Bool = false
    private(set) var errorMessage: String?
    private(set) var didSave: Bool = false
    private var didClearNameOnFocus: Bool = false

    let picker: ExercisePickerViewModel
    private let programViewModel: ProgramViewModel

    init(
        mode: ProgramEditorMode,
        program: ProgramSnapshot,
        picker: ExercisePickerViewModel,
        programViewModel: ProgramViewModel
    ) {
        self.mode = mode
        self.program = program
        self.programName = program.name
        self.programColorHex = program.colorHex ?? ""
        self.selectedWeekdays = program.weekdays
        self.picker = picker
        self.programViewModel = programViewModel
    }

    var programType: ProgramType {
        program.type
    }

    var programTitle: String {
        ProgramTypeText.title(for: programType)
    }

    var isEditing: Bool {
        mode == .edit
    }

    func updateProgramName(_ name: String) {
        programName = name
    }

    func updateProgramColorHex(_ hex: String) {
        programColorHex = hex
    }

    func toggleWeekday(_ day: ProgramWeekday) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }

    func isWeekdaySelected(_ day: ProgramWeekday) -> Bool {
        selectedWeekdays.contains(day)
    }

    func handleNameFieldFocusChange(_ isFocused: Bool) {
        if isFocused && !didClearNameOnFocus {
            programName = ""
            didClearNameOnFocus = true
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    func dismissWeekdaysRequiredAlert() {
        showWeekdaysRequiredAlert = false
    }

    func seedExercisesIfNeeded() async {
        await picker.seedExercisesIfNeeded()
    }

    func load() async {
        await picker.load()
    }

    func save() async {
        guard canStartSave() else { return }
        isSaving = true
        defer { isSaving = false }

        var snapshot = program
        snapshot.name = programName.isEmpty ? programTitle : programName
        snapshot.colorHex = programColorHex.isEmpty ? nil : programColorHex
        snapshot.weekdays = selectedWeekdays
        snapshot.exercises = positionedExercises()

        do {
            try await programViewModel.saveProgram(snapshot)
            program = snapshot
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func canStartSave() -> Bool {
        if mode == .create && selectedWeekdays.isEmpty {
            showWeekdaysRequiredAlert = true
            return false
        }
        return !isSaving
    }

    /// Editing keeps the positions the program already has and appends new exercises after them;
    /// creating numbers the selection in the order it was made.
    private func positionedExercises() -> [WorkoutExerciseSnapshot] {
        let selection = picker.selectedExercises
        guard mode == .edit else {
            return selection.enumerated().map { index, exercise in
                var exercise = exercise
                exercise.selectionIndex = index + 1
                return exercise
            }
        }
        let existingPositions = Dictionary(
            program.exercises.map { ($0.id, $0.selectionIndex) },
            uniquingKeysWith: { first, _ in first }
        )
        var nextPosition = program.exercises.map(\.selectionIndex).max() ?? 0
        return selection
            .map { exercise in
                var exercise = exercise
                if let position = existingPositions[exercise.id], position > 0 {
                    exercise.selectionIndex = position
                } else {
                    nextPosition += 1
                    exercise.selectionIndex = nextPosition
                }
                return exercise
            }
            .sorted { $0.selectionIndex < $1.selectionIndex }
    }
}
