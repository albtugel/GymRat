import SwiftUI
import SwiftData

struct ProgramCustomizeExercisesSectionView: View {
    let exerciseSeeds: [ExerciseStore.ExerciseSeed]
    @Binding var selectedExercises: [ProgramExercise]
    let isEditing: Bool
    let onToggle: (ExerciseStore.ExerciseSeed) -> Void

    @State private var searchText: String = ""

    var filteredSeeds: [ExerciseStore.ExerciseSeed] {
        if searchText.isEmpty {
            return exerciseSeeds
        }
        let query = searchText.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        return exerciseSeeds.filter {
            let name = $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            return name.contains(query)
        }
    }

    var body: some View {
        Section("exercises_section") {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("search_exercises_placeholder", text: $searchText)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            ForEach(filteredSeeds, id: \.name) { seed in
                let selectedIndex = selectedExercises.firstIndex(where: { $0.exercise.name == seed.name })
                let selected = selectedIndex.map { selectedExercises[$0] }

                ProgramCustomizeExerciseRowView(
                    seed: seed,
                    selectedExercise: selected,
                    selectionNumber: isEditing ? nil : selectedIndex.map { $0 + 1 },
                    isEditing: isEditing,
                    onToggle: onToggle
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedExercises.map(\.id))
    }
}

private struct ProgramCustomizeExerciseRowView: View {
    let seed: ExerciseStore.ExerciseSeed
    let selectedExercise: ProgramExercise?
    let selectionNumber: Int?
    let isEditing: Bool
    let onToggle: (ExerciseStore.ExerciseSeed) -> Void
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    onToggle(seed)
                }
            } label: {
                HStack {
                    Text(seed.name)
                    Spacer()
                    if let number = selectionNumber {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor)
                            Text("\(number)")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(width: 22, height: 22)
                    } else if selectedExercise != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            if isEditing {
                Button {
                    clearHistory()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .padding(6)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
                .accessibilityLabel(Text("clear_exercise_history"))
            }
        }
    }

    private func clearHistory() {
        let name = seed.name
        let predicate = #Predicate<ProgramExerciseLog> { log in
            log.exerciseName == name
        }
        let descriptor = FetchDescriptor<ProgramExerciseLog>(predicate: predicate)
        let logs = (try? context.fetch(descriptor)) ?? []
        logs.forEach { context.delete($0) }
        if context.hasChanges {
            try? context.save()
        }
    }
}
