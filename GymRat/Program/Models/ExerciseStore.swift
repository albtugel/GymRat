final class ExerciseStore {
    static let shared = ExerciseStore()

    let allExercises: [ExerciseModel] = [
        ExerciseModel(name: "Squat", category: .lower),
        ExerciseModel(name: "Deadlift", category: .lower),
        ExerciseModel(name: "Bench Press", category: .upper),
        ExerciseModel(name: "Pull Up", category: .upper),
        ExerciseModel(name: "Burpees", category: .fullBody),
        ExerciseModel(name: "Running", category: .cardio)
    ]
}
