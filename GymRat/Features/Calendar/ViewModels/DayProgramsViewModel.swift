import Foundation
import Observation

@Observable
@MainActor
final class DayProgramsViewModel {


    private(set) var dayPrograms: [Program] = []
    private(set) var draggingProgram: Program?
    private(set) var editingProgram: Program?
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

    func startDragging(_ program: Program) {
        draggingProgram = program
    }

    func stopDragging() {
        draggingProgram = nil
    }

    func setDraggingProgram(_ program: Program?) {
        draggingProgram = program
    }

    func setPrograms(_ programs: [Program]) {
        dayPrograms = programs
    }

    func edit(_ program: Program?) {
        editingProgram = program
    }

    func delete(_ program: Program) {
        let programID = program.id
        dayPrograms.removeAll { $0.id == programID }
        programViewModel.deleteProgram(program)
        reloadPrograms()
    }

    func applyReorder(_ reordered: [Program]) {
        programViewModel.reorderPrograms(reordered)
        dayPrograms = reordered
    }


    private func reloadPrograms() {
        dayPrograms = programViewModel.programs(for: selectedDate)
        prefetchImages()
    }
}
