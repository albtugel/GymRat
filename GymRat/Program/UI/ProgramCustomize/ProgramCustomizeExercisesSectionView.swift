import SwiftUI
import SwiftData

struct ProgramCustomizeExercisesSectionView: View {
    let exerciseSeeds: [ExerciseStore.ExerciseSeed]
    @Binding var selectedExercises: [ProgramExercise]
    let isEditing: Bool
    let onToggle: (ExerciseStore.ExerciseSeed) -> Void
    let onCreateCustom: (String, ExerciseCategory) -> Void

    @State private var searchText: String = ""
    @State private var selectedMuscles: Set<MuscleGroup> = []
    @State private var showCreateAlert = false
    @State private var newExerciseName = ""
    @State private var newExerciseCategory: ExerciseCategory = .strength

    var filteredSeeds: [ExerciseStore.ExerciseSeed] {
        var seeds = exerciseSeeds

        if !selectedMuscles.isEmpty {
            seeds = seeds.filter { seed in
                !selectedMuscles.isDisjoint(with: seed.muscles)
            }
        }

        if !searchText.isEmpty {
            let query = searchText.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            seeds = seeds.filter {
                let name = $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                return name.contains(query)
            }
        }

        return seeds
    }

    var body: some View {
        Section("exercises_section") {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("search_exercises_placeholder", text: $searchText)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit { searchText = searchText }
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

            // Muscle group filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MuscleGroup.allCases) { muscle in
                        Button {
                            withAnimation {
                                if selectedMuscles.contains(muscle) {
                                    selectedMuscles.remove(muscle)
                                } else {
                                    selectedMuscles.insert(muscle)
                                }
                            }
                        } label: {
                            Text(muscle.localizedLabel)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedMuscles.contains(muscle) ? Color.accentColor : Color(.systemGray5))
                                .foregroundColor(selectedMuscles.contains(muscle) ? .white : .primary)
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))

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

            // Create custom exercise button
            Button {
                showCreateAlert = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("create_exercise_button")
                }
                .foregroundColor(.accentColor)
            }
            .alert("create_exercise_title", isPresented: $showCreateAlert) {
                TextField("exercise_name_placeholder", text: $newExerciseName)
                    .autocorrectionDisabled()
                Picker("", selection: $newExerciseCategory) {
                    ForEach(ExerciseCategory.allCases) { cat in
                        Text(cat.localizedLabel).tag(cat)
                    }
                }
                Button("save_button") {
                    let trimmed = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        onCreateCustom(trimmed, newExerciseCategory)
                        newExerciseName = ""
                    }
                }
                Button("cancel_button", role: .cancel) {
                    newExerciseName = ""
                }
            } message: {
                Text("create_exercise_message")
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
        VStack(alignment: .leading, spacing: 6) {
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

                if isEditing, let exercise = selectedExercise {
                    Button {
                        clearHistory(for: exercise)
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

            // Shared history toggle removed (alert-only selection).
        }
    }

    private func clearHistory(for exercise: ProgramExercise) {
        let predicate: Predicate<ProgramExerciseLog>
        if exercise.sharedHistory {
            let exerciseId = exercise.exercise.id
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.exercise.id == exerciseId
            }
        } else {
            let programExerciseId = exercise.id
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.id == programExerciseId
            }
        }
        let descriptor = FetchDescriptor<ProgramExerciseLog>(predicate: predicate)
        let logs = (try? context.fetch(descriptor)) ?? []
        logs.forEach { context.delete($0) }
        if context.hasChanges {
            try? context.save()
        }
    }
}
