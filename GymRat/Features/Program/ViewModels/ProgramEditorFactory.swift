import Foundation

enum ProgramEditorFactory {
    @MainActor
    static func make(
        mode: ProgramEditorMode,
        program: Program,
        programViewModel: ProgramViewModel
    ) -> ProgramEditorViewModel {
        Dependencies.shared.makeProgramEditorViewModel(
            mode: mode,
            program: program,
            programViewModel: programViewModel
        )
    }
}
