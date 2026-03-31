import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProgramTableExerciseRowView: View {
    let programExercise: ProgramExercise
    let program: ProgramModel
    let selectedDate: Date
    @Binding var draggingExercise: ProgramExercise?
    @FocusState.Binding var focusedField: ProgramTableFocusField?

    @Environment(\.modelContext) var context
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var unitsManager = UnitsManager.shared
    @State var repsBySetText: [String] = []
    @State var weightsBySetText: [String] = []
    @State var durationsBySetText: [String] = []
    @State var previousRepsBySetText: [String] = []
    @State var previousWeightsBySetText: [String] = []
    @State var previousDurationsBySetText: [String] = []
    @State var setsCountText: String = ""
    @State var currentLog: ProgramExerciseLog?
    @State var setsEditedForDay: Bool = false
    @State var dataDate: Date
    @State var wasFocused: Bool = false
    @State var focusDate: Date?
    @State var editSessionDate: Date?
    @State var isLoadingLog: Bool = false
    @State var isDirty: Bool = false
    let columnSpacing: CGFloat = 8
    let rowSpacing: CGFloat = 6

    init(
        programExercise: ProgramExercise,
        program: ProgramModel,
        selectedDate: Date,
        draggingExercise: Binding<ProgramExercise?>,
        focusedField: FocusState<ProgramTableFocusField?>.Binding
    ) {
        self.programExercise = programExercise
        self.program = program 
        self.selectedDate = selectedDate
        self._draggingExercise = draggingExercise
        self._focusedField = focusedField
        _setsCountText = State(initialValue: String(max(1, programExercise.sets)))
        _dataDate = State(initialValue: selectedDate.startOfDay)
    }

    var setsCount: Int {
        let parsed = Int(setsCountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? programExercise.sets
        return min(10, max(1, parsed))
    }

    var seed: ExerciseStore.ExerciseSeed? {
        ExerciseStore.shared.seeds.first { $0.name == programExercise.exercise.name }
    }

    var inputType: ExerciseInputType {
        seed?.inputType ?? (isCardio ? .cardioDistance : .strength)
    }

    var isCardio: Bool {
        programExercise.exercise.category == .cardio
    }

    var showsDuration: Bool {
        inputType == .cardioDistance || inputType == .cardioJump || inputType == .timed
    }

    var showsWeight: Bool {
        inputType == .strength || inputType == .timed
    }

    var showsReps: Bool {
        inputType != .timed
    }

    var weightPlaceholder: String {
        unitsManager.currentWeightUnit.label
    }

    var weightKeyboard: UIKeyboardType {
        inputType == .strength ? .decimalPad : .numberPad
    }

    var durationPlaceholder: String {
        String(localized: "dur_label")
    }

    var durationKeyboard: UIKeyboardType {
        .numbersAndPunctuation
    }

    var durationFont: Font {
        inputType == .strength ? .subheadline : .caption2
    }

    var statBoxWidth: CGFloat {
        60
    }

    var repsPlaceholder: String {
        switch inputType {
        case .strength: return String(localized: "reps_label")
        case .cardioDistance: return unitsManager.currentDistanceUnit.label
        case .cardioJump: return String(localized: "jumps_label")
        case .timed: return String(localized: "reps_label")
        }
    }

    var setsTitle: String {
        switch inputType {
        case .strength, .timed: return String(localized: "sets_label")
        case .cardioDistance, .cardioJump: return String(localized: "rounds_label")
        }
    }
}
