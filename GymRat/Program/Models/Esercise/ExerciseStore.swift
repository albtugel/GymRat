final class ExerciseStore {
    static let shared = ExerciseStore()

    let allExercises: [ExerciseModel] = [
        ExerciseModel(name: "Squat", category: .lowerBody),
        ExerciseModel(name: "Deadlift", category: .lowerBody),
        ExerciseModel(name: "Bench Press", category: .upperBody),
        ExerciseModel(name: "Pull Up", category: .upperBody),
        ExerciseModel(name: "Burpees", category: .fullBody),
        ExerciseModel(name: "Running", category: .cardio),
        ExerciseModel(name: "Box Jumps", category: .crossfit),
        ExerciseModel(name: "Kettlebell Swings", category: .crossfit),
    ]
}
