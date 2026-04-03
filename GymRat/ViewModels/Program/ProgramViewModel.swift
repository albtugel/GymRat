import Foundation
import Observation

@Observable
@MainActor
final class ProgramViewModel {

    // MARK: - State
    private(set) var programs: [Program] = []
    private(set) var customPrograms: [Program] = []
    private(set) var dayPrograms: [Date: [Program]] = [:]
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let exerciseService: ExerciseServiceProtocol
    private let programService: ProgramServiceProtocol
    private let assignmentService: ProgramAssignmentServiceProtocol
    private let dataResetService: DataResetServiceProtocol

    init(
        exerciseService: ExerciseServiceProtocol,
        programService: ProgramServiceProtocol,
        assignmentService: ProgramAssignmentServiceProtocol,
        dataResetService: DataResetServiceProtocol
    ) {
        self.exerciseService = exerciseService
        self.programService = programService
        self.assignmentService = assignmentService
        self.dataResetService = dataResetService
    }

    // MARK: - Intents
    func resolvePrograms(for date: Date) -> [Program] {
        guard let weekday = ProgramWeekDayHelper.from(date: date) else { return [] }
        return customPrograms.filter { ProgramModelMapper.weekdays(for: $0).contains(weekday) }
    }

    var hasCustomPrograms: Bool {
        !customPrograms.isEmpty
    }

    var customProgramIds: [UUID] {
        customPrograms.map(\.id)
    }

    func makeProgram(for type: ProgramType) -> Program {
        ProgramModel(
            name: resolveProgramTitle(for: type),
            typeRaw: type.rawValue
        )
    }

    func makeProgram(name: String, typeRaw: String) -> Program {
        ProgramModel(name: name, typeRaw: typeRaw)
    }

    func resolveProgramTitle(for type: ProgramType) -> String {
        ProgramTypeDisplay.title(for: type)
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Loading
    func loadPrograms() async {
        isLoading = true
        defer { isLoading = false }
        do {
            programs = try await programService.fetchPrograms()
            customPrograms = programs
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadDayPrograms() async {
        do {
            let assignments = try await assignmentService.fetchAssignments()
            dayPrograms = [:]
            for assign in assignments {
                let day = assign.date.startOfDay
                if day >= Date().startOfDay {
                    dayPrograms[day, default: []].append(assign.program)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func seedExercisesIfNeeded() async {
        do {
            try await exerciseService.seedIfNeeded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Actions
    func addProgram(_ program: Program) async {
        do {
            try await programService.saveProgram(program)
            appendProgram(program)
            let assignments = makeAssignments(for: program)
            applyAssignments(assignments, program: program)
            try await insertAssignments(assignments)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteProgram(_ program: Program) async {
        do {
            try await programService.deleteProgram(program)
            programs.removeAll { $0.id == program.id }
            customPrograms.removeAll { $0.id == program.id }

            try await assignmentService.deleteAssignments(forProgramId: program.id)

            for key in dayPrograms.keys {
                dayPrograms[key]?.removeAll { $0.id == program.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePrograms(at offsets: IndexSet) async {
        for index in offsets {
            let program = customPrograms[index]
            await deleteProgram(program)
        }
    }

    func reorderExercises(in program: Program, from source: IndexSet, to destination: Int) async {
        do {
            try await programService.reorderExercises(in: program, from: source, to: destination)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPrograms() {
        programs = []
        customPrograms = []
        dayPrograms = [:]
    }

    func resetAllData() async {
        do {
            try await dataResetService.resetAllData()
            resetPrograms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyProgramOrder(_ reordered: [Program]) {
        let ids = reordered.map(\.id)
        var updated = customPrograms
        let indices = updated.enumerated().compactMap { index, element in
            ids.contains(element.id) ? index : nil
        }
        if indices.count == reordered.count {
            for (orderIndex, programIndex) in indices.enumerated() {
                updated[programIndex] = reordered[orderIndex]
            }
            customPrograms = updated
        } else {
            updated.removeAll { ids.contains($0.id) }
            updated.append(contentsOf: reordered)
            customPrograms = updated
        }
    }

    // MARK: - Helpers
    private func appendProgram(_ program: Program) {
        programs.append(program)
        customPrograms.append(program)
    }

    private func makeAssignments(for program: Program) -> [ProgramAssignment] {
        let calendar = AppCalendar.calendar
        let startOfWeek = Date().startOfWeek
        let weekdays = ProgramModelMapper.weekdays(for: program)
        return weekdays.compactMap { weekday in
            calendar.nextDate(
                after: startOfWeek.addingTimeInterval(-1),
                matching: DateComponents(weekday: ProgramWeekDayHelper.systemWeekdayNumber(for: weekday)),
                matchingPolicy: .nextTime
            ).map { ProgramAssignment(program: program, date: $0) }
        }
    }

    private func applyAssignments(_ assignments: [ProgramAssignment], program: Program) {
        for assignment in assignments {
            let day = assignment.date.startOfDay
            dayPrograms[day, default: []].append(program)
        }
    }

    private func insertAssignments(_ assignments: [ProgramAssignment]) async throws {
        guard !assignments.isEmpty else { return }
        try await assignmentService.insertAssignments(assignments)
    }
}
