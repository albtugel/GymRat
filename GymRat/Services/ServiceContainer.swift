@MainActor
final class ServiceContainer {
    static let shared = ServiceContainer()

    private init() {}

    var exerciseService: ExerciseServiceProtocol { AppDependencies.shared.exerciseService }
    var programService: ProgramServiceProtocol { AppDependencies.shared.programService }
    var programAssignmentService: ProgramAssignmentServiceProtocol { AppDependencies.shared.programAssignmentService }
    var programExerciseLogService: ProgramExerciseLogServiceProtocol { AppDependencies.shared.programExerciseLogService }
    var timelineItemService: TimelineItemServiceProtocol { AppDependencies.shared.timelineItemService }
    var dataResetService: DataResetServiceProtocol { AppDependencies.shared.dataResetService }
    var calendarService: CalendarServiceProtocol { AppDependencies.shared.calendarService }
}
