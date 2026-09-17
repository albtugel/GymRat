import Foundation
import Observation

@Observable
@MainActor
final class DayProgramsViewModel {
    private(set) var dayPrograms: [ProgramSnapshot] = []
    private(set) var draggingProgram: ProgramSnapshot?
    private(set) var editingProgram: ProgramSnapshot?
    private(set) var selectedDate: Date

    private let programViewModel: ProgramViewModel
    private let imagePrefetcher: ExerciseImagePrefetcher

    /// Only resolves the day's programs. Image warm-up starts with `prefetchImages()` once the view is
    /// on screen, so an instance built and discarded during a render never touches the network.
    init(selectedDate: Date, programViewModel: ProgramViewModel, imagePrefetcher: ExerciseImagePrefetcher) {
        self.selectedDate = selectedDate
        self.programViewModel = programViewModel
        self.imagePrefetcher = imagePrefetcher
        dayPrograms = programViewModel.programs(for: selectedDate)
    }

    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        reloadPrograms()
    }

    func reload() {
        reloadPrograms()
    }

    func prefetchImages() {
        imagePrefetcher.prefetch(
            exerciseNames: dayPrograms.flatMap { $0.exercises.map(\.exercise.name) }
        )
    }

    func setDraggingProgram(_ program: ProgramSnapshot?) {
        draggingProgram = program
    }

    func setPrograms(_ programs: [ProgramSnapshot]) {
        dayPrograms = programs
    }

    func edit(_ program: ProgramSnapshot?) {
        editingProgram = program
    }

    func delete(_ program: ProgramSnapshot) {
        dayPrograms.removeAll { $0.id == program.id }
        Task { [weak self] in
            guard let self else { return }
            await programViewModel.deleteProgram(id: program.id)
            reloadPrograms()
        }
    }

    func applyReorder(_ reordered: [ProgramSnapshot]) {
        programViewModel.reorderPrograms(reordered)
        dayPrograms = reordered
    }

    private func reloadPrograms() {
        dayPrograms = programViewModel.programs(for: selectedDate)
        prefetchImages()
    }
}
