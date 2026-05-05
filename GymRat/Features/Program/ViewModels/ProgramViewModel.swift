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
    private let exerciseService: ExerciseServiceType
    private let programService: ProgramServiceType
    private let assignmentService: ScheduleServiceType
    private let dataResetService: DataResetServiceType

    init(
        exerciseService: ExerciseServiceType,
        programService: ProgramServiceType,
        assignmentService: ScheduleServiceType,
        dataResetService: DataResetServiceType
    ) {
        self.exerciseService = exerciseService
        self.programService = programService
        self.assignmentService = assignmentService
        self.dataResetService = dataResetService
    }

    // MARK: - Intents
    func programs(for date: Date) -> [Program] {
        guard let weekday = ProgramWeekdayHelper.from(date: date) else { return [] }
        return customPrograms.filter { ProgramMapper.weekdays(for: $0).contains(weekday) }
    }

    var hasCustomPrograms: Bool {
        !customPrograms.isEmpty
    }

    var customProgramIds: [UUID] {
        customPrograms.map(\.id)
    }

    func makeProgram(for type: ProgramType) -> Program {
        Program(
            name: title(for: type),
            typeRaw: type.rawValue
        )
    }

    func makeProgram(name: String, typeRaw: String) -> Program {
        Program(name: name, typeRaw: typeRaw)
    }

    func title(for type: ProgramType) -> String {
        ProgramTypeText.title(for: type)
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

    func loadSchedules() async {
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
            try await programService.save(program)
            appendProgram(program)
            let assignments = buildSchedule(for: program)
            applySchedule(assignments, program: program)
            try await saveSchedule(assignments)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteProgram(_ program: Program) async {
        do {
            let programID = program.id
            try await programService.deleteProgram(program)
            programs.removeAll { $0.id == programID }
            customPrograms.removeAll { $0.id == programID }

            try await assignmentService.deleteAssignments(forProgramId: programID)

            for key in dayPrograms.keys {
                dayPrograms[key]?.removeAll { $0.id == programID }
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

    func reorderPrograms(_ reordered: [Program]) {
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

    private func buildSchedule(for program: Program) -> [ScheduleItem] {
        let calendar = AppCalendar.calendar
        let startOfWeek = Date().startOfWeek
        let weekdays = ProgramMapper.weekdays(for: program)
        return weekdays.compactMap { weekday in
            calendar.nextDate(
                after: startOfWeek.addingTimeInterval(-1),
                matching: DateComponents(weekday: ProgramWeekdayHelper.systemWeekdayNumber(for: weekday)),
                matchingPolicy: .nextTime
            ).map { ScheduleItem(program: program, date: $0) }
        }
    }

    private func applySchedule(_ assignments: [ScheduleItem], program: Program) {
        for assignment in assignments {
            let day = assignment.date.startOfDay
            dayPrograms[day, default: []].append(program)
        }
    }

    private func saveSchedule(_ assignments: [ScheduleItem]) async throws {
        guard !assignments.isEmpty else { return }
        try await assignmentService.saveSchedule(assignments)
    }
}
