//
//  WorkoutDetailView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var session: WorkoutSession

    var body: some View {
        List {
            ForEach(session.exercises.indices, id: \.self) { index in
                ExerciseRowView(exercise: session.exercises[index])
            }
        }
        .navigationTitle("Тренировка")
    }
}
