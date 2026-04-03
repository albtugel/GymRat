import SwiftUI

struct ProgramCustomizeInfoSectionView: View {
    private let programName: String
    private let programColor: Color
    @FocusState.Binding private var nameFieldIsFocused: Bool
    private let onProgramNameChange: (String) -> Void
    private let onProgramColorChange: (Color) -> Void
    private let onNameFieldFocusChange: (Bool) -> Void

    init(
        programName: String,
        programColor: Color,
        nameFieldIsFocused: FocusState<Bool>.Binding,
        onProgramNameChange: @escaping (String) -> Void,
        onProgramColorChange: @escaping (Color) -> Void,
        onNameFieldFocusChange: @escaping (Bool) -> Void
    ) {
        self.programName = programName
        self.programColor = programColor
        self._nameFieldIsFocused = nameFieldIsFocused
        self.onProgramNameChange = onProgramNameChange
        self.onProgramColorChange = onProgramColorChange
        self.onNameFieldFocusChange = onNameFieldFocusChange
    }

    // MARK: - Body
    var body: some View {
        Section("program_info_section") {
            HStack {
                TextField("program_name_placeholder", text: programNameBinding)
                    .focused($nameFieldIsFocused)
                    .submitLabel(.done)
                    .onSubmit { nameFieldIsFocused = false }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { nameFieldIsFocused = true }
            .onChange(of: nameFieldIsFocused) { _, isFocused in
                onNameFieldFocusChange(isFocused)
            }

            ColorPicker("program_color_label", selection: programColorBinding, supportsOpacity: false)
        }
    }

    // MARK: - Helpers
    private var programNameBinding: Binding<String> {
        Binding(
            get: { programName },
            set: { onProgramNameChange($0) }
        )
    }

    private var programColorBinding: Binding<Color> {
        Binding(
            get: { programColor },
            set: { onProgramColorChange($0) }
        )
    }
}
