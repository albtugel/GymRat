//
//  ProgramCustomizeContentView.swift
//  GymRat
//
//  Created by Alik on 1/30/26.
//

import SwiftUI

struct ProgramCustomizeContentView: View {

    @Binding var baseProgram: ProgramModel
    @Binding var name: String
    @Binding var details: String
    @Binding var weekdays: Set<ProgramWeekDay>
    @Binding var programType: ProgramType
    @Binding var selectedExercises: Set<ExerciseModel>

    let filteredExercises: [ExerciseModel]
    let mode: ProgramCustomizeMode
    let saveAction: () -> Void

    var body: some View {
        NavigationStack {
            Form {

                Section("Program Info") {
                    TextField("Name", text: $name)

                    Picker("Program Type", selection: $programType) {
                        ForEach(ProgramType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                }

                Section("Exercises") {
                    ForEach(filteredExercises, id: \.id) { exercise in
                        HStack {
                            Text(exercise.name)
                            Spacer()
                            if selectedExercises.contains(exercise) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedExercises.contains(exercise) {
                                selectedExercises.remove(exercise)
                            } else {
                                selectedExercises.insert(exercise)
                            }
                        }
                    }
                }
            }

            Button("Save", action: saveAction)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
        }
    }
}
