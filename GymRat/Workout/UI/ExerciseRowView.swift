import SwiftUI

struct ExerciseRowView: View {
    var exercise: Exercise

    @State private var weightInput = ""
    @State private var repsInput = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name)
                .font(.headline)

            HStack {
                TextField("weight_placeholder", text: $weightInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                TextField("reps_placeholder", text: $repsInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Button("save_button") {
                    if let weight = Double(weightInput), let reps = Int(repsInput) {
                        let log = ExerciseLog(weight: weight, reps: reps)
                        exercise.logs.append(log)
                        weightInput = ""
                        repsInput = ""
                    }
                }
            }

            if let lastLog = exercise.logs.last {
                let text = String(
                    format: String(localized: "last_time_format"),
                    locale: .current,
                    lastLog.weight,
                    lastLog.reps
                )
                Text(text)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
