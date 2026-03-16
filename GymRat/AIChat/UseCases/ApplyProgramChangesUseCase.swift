import Foundation

struct ApplyProgramChangesUseCase {
    let repository: ProgramRepository

    func execute(request: ProgramChangeRequest) {
        guard let program = repository.fetchProgram(id: request.programId) else { return }

        for action in request.actions {
            switch action {
            case .setDays(let dayNumbers):
                let days = dayNumbers.compactMap { ProgramWeekDay(calendarNumber: $0) }
                program.weekdays = Set(days)
            case .addExercise(let name):
                let exercise = repository.fetchOrCreateExercise(name: name)
                if !program.exercises.contains(where: { $0.exercise.name == name }) {
                    program.exercises.append(ProgramExercise(exercise: exercise))
                }
            case .removeExercise(let name):
                program.exercises.removeAll { $0.exercise.name == name }
            case .reorderExercises(let order):
                var ordered: [ProgramExercise] = []
                let nameToExercise = Dictionary(uniqueKeysWithValues: program.exercises.map { ($0.exercise.name, $0) })
                for name in order {
                    if let exercise = nameToExercise[name] {
                        ordered.append(exercise)
                    }
                }
                let remaining = program.exercises.filter { !ordered.contains($0) }
                program.exercises = ordered + remaining
            case .setSets(let exerciseName, let sets):
                if let item = program.exercises.first(where: { $0.exercise.name == exerciseName }) {
                    item.sets = max(1, sets)
                }
            }
        }

        try? repository.save()
    }
}
