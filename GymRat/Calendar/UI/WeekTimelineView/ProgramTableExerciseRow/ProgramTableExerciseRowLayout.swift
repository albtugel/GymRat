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
                    title: setsTitle,
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
                                previousDuration: index < previousDurationsBySetText.count ? previousDurationsBySetText[index] : "",
                                repsPlaceholder: repsPlaceholder,
                                weightPlaceholder: weightPlaceholder,
                                weightKeyboard: weightKeyboard,
                                durationPlaceholder: durationPlaceholder,
                                durationKeyboard: .default,
                                durationFont: durationFont,
                                showsDuration: showsDuration,
                                showsWeight: !isCardio,
                                boxWidth: statBoxWidth,
                                currentReps: repsBinding(index: index),
                                currentWeight: weightBinding(index: index),
                                currentDuration: durationBinding(index: index),
                                programExerciseId: programExercise.id,
                                focusedField: $focusedField,
                                columnSpacing: columnSpacing
                            )
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, 2)
                }
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .onAppear { loadLog() }
        .onChange(of: selectedDate) {
            saveCurrentLogIfNeeded()
            loadLog()
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveExerciseLogs)) { _ in
            saveCurrentLogIfNeeded()
        }
        .onChange(of: focusedField) { oldValue, newValue in
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
            return NSItemProvider(item: Data() as NSData, typeIdentifier: UTType.data.identifier)
        }
        .onDrop(
            of: [UTType.data],
            delegate: ProgramExerciseDropDelegate(
                item: programExercise,
                program: program,
                dragging: $draggingExercise
            )
        )
    }
}
