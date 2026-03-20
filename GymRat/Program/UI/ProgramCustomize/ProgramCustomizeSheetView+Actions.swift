import SwiftUI
import SwiftData

extension ProgramCustomizeSheetView {
    func toggleExercise(_ seed: ExerciseStore.ExerciseSeed) {
        if let index = selectedExercises.firstIndex(where: { $0.exercise.name == seed.name }) {
            selectedExercises.remove(at: index)
            return
        }

        let exercise = fetchOrCreateExercise(seed)
        let existsInOtherPrograms = allPrograms
            .filter { $0.id != program.id }
            .flatMap { $0.exercises }
            .contains { $0.exercise.id == exercise.id }

        if existsInOtherPrograms {
            pendingSeed = seed
            showSharedHistoryAlert = true
        } else {
            selectedExercises.append(ProgramExercise(exercise: exercise, sharedHistory: false))
        }
    }

    func fetchOrCreateExercise(_ seed: ExerciseStore.ExerciseSeed) -> ExerciseModel {
        let name = seed.name
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: #Predicate<ExerciseModel> { $0.name == name })
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }

        let newExercise = ExerciseModel(name: seed.name, category: seed.category)
        context.insert(newExercise)
        try? context.save()
        return newExercise
    }

    func addPendingExercise(sharedHistory: Bool) {
        guard let seed = pendingSeed else { return }
        let exercise = fetchOrCreateExercise(seed)
        if selectedExercises.contains(where: { $0.exercise.id == exercise.id }) {
            pendingSeed = nil
            return
        }
        selectedExercises.append(ProgramExercise(exercise: exercise, sharedHistory: sharedHistory))
        pendingSeed = nil
    }

    func saveProgram() {
        guard !isSaving else { return }
        isSaving = true

        program.name = programName.isEmpty ? program.type.title : programName

        if mode == .edit {
            var ordered: [ProgramExercise] = []
            let selectedIds = Set(selectedExercises.map { $0.id })

            ordered.append(contentsOf: program.exercises.filter { selectedIds.contains($0.id) })

            let existingIds = Set(ordered.map { $0.id })
            let newOnes = selectedExercises.filter { !existingIds.contains($0.id) }

            let maxSelectionIndex = ordered.map { $0.selectionIndex }.max() ?? 0
            var nextSelectionIndex = maxSelectionIndex
            for exercise in newOnes {
                if exercise.selectionIndex == 0 {
                    nextSelectionIndex += 1
                    exercise.selectionIndex = nextSelectionIndex
                }
            }
            ordered.append(contentsOf: newOnes)

            program.exercises = ordered
        } else {
            for (index, exercise) in selectedExercises.enumerated() {
                exercise.selectionIndex = index + 1
            }
            program.exercises = selectedExercises
        }

        program.weekdays = selectedWeekdays

        if mode == .create {
            if !programManager.customPrograms.contains(where: { $0.id == program.id }) {
                context.insert(program)
                programManager.customPrograms.append(program)
            }
        }

        if context.hasChanges {
            try? context.save()
        }

        dismiss()
    }
}
