import Foundation
import Observation

@Observable
@MainActor
final class ProgramForSelectedDayViewModel {

    // MARK: - State
    private(set) var dayPrograms: [Program] = []
    private(set) var draggingProgram: Program?
    private(set) var editingProgram: Program?
    private(set) var selectedDate: Date

    // MARK: - Dependencies
    private let programViewModel: ProgramViewModel

    init(selectedDate: Date, programViewModel: ProgramViewModel) {
        self.selectedDate = selectedDate
        self.programViewModel = programViewModel
        reloadPrograms()
    }

    // MARK: - Intents
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        reloadPrograms()
    }

    func updatePrograms() {
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

    func updateDayPrograms(_ programs: [Program]) {
        dayPrograms = programs
    }

    func setEditingProgram(_ program: Program?) {
        editingProgram = program
    }

    func applyReorder(_ reordered: [Program]) {
        programViewModel.applyProgramOrder(reordered)
        dayPrograms = reordered
    }

    // MARK: - Helpers
    private func reloadPrograms() {
        dayPrograms = programViewModel.resolvePrograms(for: selectedDate)
    }
}
