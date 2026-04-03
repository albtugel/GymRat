import SwiftUI

struct ProgramTableExerciseRowSetsSectionView: View {
    private let viewModel: ProgramTableExerciseRowViewModel
    @FocusState.Binding private var focusedField: ProgramTableFocusField?

    private let columnSpacing: CGFloat = 8
    private let rowSpacing: CGFloat = 6
    private let statBoxWidth: CGFloat = 60

    init(
        viewModel: ProgramTableExerciseRowViewModel,
        focusedField: FocusState<ProgramTableFocusField?>.Binding
    ) {
        self.viewModel = viewModel
        self._focusedField = focusedField
    }

    // MARK: - Body
    var body: some View {
        ProgramTableExerciseRowSetsContentView(
            viewModel: viewModel,
            focusedField: $focusedField,
            setsCountText: setsCountBinding,
            weightKeyboard: weightKeyboard,
            durationKeyboard: durationKeyboard,
            durationFont: durationFont,
            columnSpacing: columnSpacing,
            rowSpacing: rowSpacing,
            statBoxWidth: statBoxWidth
        )
    }

    // MARK: - Helpers
    private var setsCountBinding: Binding<String> {
        Binding(
            get: { viewModel.setsCountTextValue() },
            set: { viewModel.updateSetsCountText($0) }
        )
    }

    private var weightKeyboard: UIKeyboardType {
        viewModel.inputType == .strength ? .decimalPad : .numberPad
    }

    private var durationKeyboard: UIKeyboardType {
        .numbersAndPunctuation
    }

    private var durationFont: Font {
        viewModel.inputType == .strength ? .subheadline : .caption2
    }
}
