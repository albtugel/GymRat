import SwiftUI

struct WorkoutDetailView: View {
    var session: WorkoutSession

    var body: some View {
        List {
            ForEach(session.exercises.indices, id: \.self) { index in
                ExerciseRowView(exercise: session.exercises[index])
            }
        }
        .navigationTitle("workout_title")
    }
}
