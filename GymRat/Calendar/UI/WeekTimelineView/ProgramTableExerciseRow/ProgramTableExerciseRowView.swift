import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProgramTableExerciseRowView: View {
    let programExercise: ProgramExercise
    let selectedDate: Date
    let program: ProgramModel
    @Binding var draggingExercise: ProgramExercise?
    @FocusState.Binding var focusedField: ProgramTableFocusField?

    @Environment(\.modelContext) var context
    @State var repsBySetText: [String] = []
    @State var weightsBySetText: [String] = []
    @State var previousRepsBySetText: [String] = []
    @State var previousWeightsBySetText: [String] = []
    @State var setsCountText: String = ""
    @State var currentLog: ProgramExerciseLog?
    @State var setsEditedForDay: Bool = false
    @State var dataDate: Date
    @State var wasFocused: Bool = false
    @State var focusDate: Date?
    @State var editSessionDate: Date?
    @State var isLoadingLog: Bool = false
    @State var isDirty: Bool = false
    private let columnSpacing: CGFloat = 8
    private let rowSpacing: CGFloat = 6

    init(
        programExercise: ProgramExercise,
        selectedDate: Date,
        program: ProgramModel,
        draggingExercise: Binding<ProgramExercise?>,
        focusedField: FocusState<ProgramTableFocusField?>.Binding
    ) {
        self.programExercise = programExercise
        self.selectedDate = selectedDate
        self.program = program
        self._draggingExercise = draggingExercise
        self._focusedField = focusedField
        _setsCountText = State(initialValue: String(max(1, programExercise.sets)))
        _dataDate = State(initialValue: selectedDate.startOfDay)
    }

    var setsCount: Int {
        let parsed = Int(setsCountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? programExercise.sets
        return min(10, max(1, parsed))
    }
}
