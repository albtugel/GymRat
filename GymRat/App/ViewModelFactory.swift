import SwiftUI

/// Builds the view models that views own. Views read it from the environment, so a screen or a
/// preview can be assembled with fakes instead of reaching for the app-wide `Dependencies`.
@MainActor
protocol ViewModelFactory {
    func makeSettingsViewModel() -> SettingsViewModel
    func makePoseTestViewModel() -> PoseTestViewModel
    func makeExerciseRowViewModel(programExercise: WorkoutExerciseSnapshot, selectedDate: Date) -> ExerciseRowViewModel
    func makeProgramEditorViewModel(
        mode: ProgramEditorMode,
        program: ProgramSnapshot,
        programViewModel: ProgramViewModel
    ) -> ProgramEditorViewModel
    func makeAIPlanEditViewModel(programEditorViewModel: ProgramEditorViewModel) -> AIPlanEditViewModel
    func makeDayProgramsViewModel(selectedDate: Date, programViewModel: ProgramViewModel) -> DayProgramsViewModel
    func makeExerciseDetailsViewModel(seed: ExerciseRepo.ExerciseSeed) -> ExerciseDetailsViewModel
}

extension EnvironmentValues {
    /// Injected once at the app root (`GymRatApp`). Any view tree that builds view models must have one.
    @Entry var viewModelFactory: any ViewModelFactory = UnavailableViewModelFactory()
}

/// Default for the environment key, so a view tree assembled without a factory fails with a
/// clear message instead of an opaque crash.
private struct UnavailableViewModelFactory {
    private func missing() -> Never {
        preconditionFailure("No ViewModelFactory in the environment. Inject one with .environment(\\.viewModelFactory, ...).")
    }
}

extension UnavailableViewModelFactory: ViewModelFactory {
    func makeSettingsViewModel() -> SettingsViewModel { missing() }
    func makePoseTestViewModel() -> PoseTestViewModel { missing() }

    func makeExerciseRowViewModel(programExercise: WorkoutExerciseSnapshot, selectedDate: Date) -> ExerciseRowViewModel { missing() }

    func makeProgramEditorViewModel(
        mode: ProgramEditorMode,
        program: ProgramSnapshot,
        programViewModel: ProgramViewModel
    ) -> ProgramEditorViewModel { missing() }

    func makeAIPlanEditViewModel(programEditorViewModel: ProgramEditorViewModel) -> AIPlanEditViewModel { missing() }

    func makeDayProgramsViewModel(selectedDate: Date, programViewModel: ProgramViewModel) -> DayProgramsViewModel { missing() }

    func makeExerciseDetailsViewModel(seed: ExerciseRepo.ExerciseSeed) -> ExerciseDetailsViewModel { missing() }
}
