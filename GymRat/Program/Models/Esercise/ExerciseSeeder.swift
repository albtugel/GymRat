import SwiftData

enum ExerciseSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let fetch = FetchDescriptor<ExerciseModel>()
        let existing = (try? context.fetch(fetch)) ?? []
        let existingNames = Set(existing.map { $0.name.lowercased() })

        var didInsert = false
        for seed in ExerciseStore.shared.seeds {
            let key = seed.name.lowercased()
            if !existingNames.contains(key) {
                context.insert(ExerciseModel(name: seed.name, category: seed.category))
                didInsert = true
            }
        }

        if didInsert {
            try? context.save()
        }
    }
}
