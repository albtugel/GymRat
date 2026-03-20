import SwiftUI

struct ProgramCustomizeInfoSectionView: View {
    @Binding var programName: String
    @FocusState.Binding var nameFieldIsFocused: Bool
    @State private var didClearOnFocus = false

    var body: some View {
        Section("program_info_section") {
            HStack {
                TextField("program_name_placeholder", text: $programName)
                    .focused($nameFieldIsFocused)
                    .submitLabel(.done)
                    .onSubmit { nameFieldIsFocused = false }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { nameFieldIsFocused = true }
            .onChange(of: nameFieldIsFocused) { _, isFocused in
                if isFocused && !didClearOnFocus {
                    programName = ""
                    didClearOnFocus = true
                }
            }
        }
    }
}
