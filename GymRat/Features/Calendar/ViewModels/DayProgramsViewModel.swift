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

    init(selectedDate: Date, programViewModel: ProgramViewModel) {
        self.selectedDate = selectedDate
        self.programViewModel = programViewModel
        reloadPrograms()
    }


    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        reloadPrograms()
    }

    func reload() {
        reloadPrograms()
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

    func applyReorder(_ reordered: [Program]) {
        programViewModel.reorderPrograms(reordered)
        dayPrograms = reordered
    }


    private func reloadPrograms() {
        dayPrograms = programViewModel.programs(for: selectedDate)
    }
}
