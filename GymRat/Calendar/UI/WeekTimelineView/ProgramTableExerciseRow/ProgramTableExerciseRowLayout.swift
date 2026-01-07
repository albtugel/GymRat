import SwiftUI
import SwiftData
import UniformTypeIdentifiers

extension ProgramTableExerciseRowView {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(programExercise.exercise.name)
                    .font(.headline)

                Spacer()

                if programExercise.selectionIndex > 0 {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                        Text("\(programExercise.selectionIndex)")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 22, height: 22)
                }
            }

            HStack(alignment: .top, spacing: 12) {
                SetsBoxView(
                    setsText: setsCountBinding,
                    focusedField: .sets(programExercise.id),
                    focusedFieldBinding: $focusedField
                )

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: rowSpacing) {
                        ForEach(0..<setsCount, id: \.self) { index in
                            SetRowView(
                                index: index,
                                previousReps: index < previousRepsBySetText.count ? previousRepsBySetText[index] : "",
                                previousWeight: index < previousWeightsBySetText.count ? previousWeightsBySetText[index] : "",
                                currentReps: repsBinding(index: index),
                                currentWeight: weightBinding(index: index),
                                programExerciseId: programExercise.id,
                                focusedField: $focusedField,
                                columnSpacing: columnSpacing
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .onAppear { loadLog() }
        .onChange(of: selectedDate) { _ in
            saveCurrentLogIfNeeded()
            loadLog()
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveExerciseLogs)) { _ in
            saveCurrentLogIfNeeded()
        }
        .onChange(of: focusedField) { newValue in
            let isFocused = isRowFocused(newValue)
            if !wasFocused && isFocused {
                focusDate = dataDate
                if editSessionDate == nil {
                    editSessionDate = dataDate
                }
            } else if wasFocused && !isFocused {
                if focusDate == dataDate {
                    saveCurrentLogIfNeeded()
                }
            }
            wasFocused = isFocused
        }
        .onDisappear {
            saveCurrentLogIfNeeded()
        }
        .onDrag {
            draggingExercise = programExercise
            return NSItemProvider(item: Data() as NSData, typeIdentifier: UTType.gymratExercise.identifier)
        }
        .onDrop(
            of: [UTType.gymratExercise],
            delegate: ProgramExerciseDropDelegate(
                item: programExercise,
                program: program,
                dragging: $draggingExercise
            )
        )
    }
}
