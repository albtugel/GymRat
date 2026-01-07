//
//  ExerciseRowView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct ExerciseRowView: View {
    @ObservedObject var exercise: Exercise

    @State private var weightInput = ""
    @State private var repsInput = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.headline)

            HStack {
                TextField("Вес", text: $weightInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                TextField("Повторы", text: $repsInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Button("Сохранить") {
                    if let weight = Double(weightInput), let reps = Int(repsInput) {
                        let log = ExerciseLog(weight: weight, reps: reps)
                        exercise.logs.append(log)
                        weightInput = ""
                        repsInput = ""
                    }
                }
            }

            if let lastLog = exercise.logs.last {
                Text("Прошлый раз: \(lastLog.weight) кг × \(lastLog.reps) повторений")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
