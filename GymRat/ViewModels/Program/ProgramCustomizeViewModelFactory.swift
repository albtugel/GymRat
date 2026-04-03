import Foundation

enum ProgramCustomizeViewModelFactory {
    @MainActor
    static func make(
        mode: ProgramCustomizeMode,
        program: Program,
        programViewModel: ProgramViewModel
    ) -> ProgramCustomizeViewModel {
        AppDependencies.shared.makeProgramCustomizeViewModel(
            mode: mode,
            program: program,
            programViewModel: programViewModel
        )
    }
}
