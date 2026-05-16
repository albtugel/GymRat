import Foundation

enum EnglishLocalization {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        let value = bundle.localizedString(forKey: key, value: key, table: nil)
        return value == key ? key : value
    }
}

extension MuscleGroup {
    static func map(
        targetMuscles: [String],
        bodyParts: [String],
        secondaryMuscles: [String]
    ) -> [MuscleGroup] {
        let orderedValues = targetMuscles + secondaryMuscles + bodyParts
        var result: [MuscleGroup] = []

        for rawValue in orderedValues {
            let normalized = rawValue.normalizedExerciseToken
            if let direct = aliases[normalized] {
                result.append(direct)
                continue
            }
            for (alias, group) in aliases where normalized.contains(alias) {
                result.append(group)
                break
            }
        }

        return result.uniqued()
    }

    private static let aliases: [String: MuscleGroup] = [
        "pectorals": .chest,
        "pecs": .chest,
        "chest": .chest,
        "serratus anterior": .chest,
        "back": .back,
        "lats": .back,
        "latissimus dorsi": .back,
        "traps": .back,
        "trapezius": .back,
        "spine": .back,
        "spinal erectors": .back,
        "erector spinae": .back,
        "upper back": .back,
        "delts": .shoulders,
        "deltoids": .shoulders,
        "shoulders": .shoulders,
        "shoulder": .shoulders,
        "biceps": .biceps,
        "biceps brachii": .biceps,
        "brachialis": .biceps,
        "forearms": .biceps,
        "forearm": .biceps,
        "triceps": .triceps,
        "triceps brachii": .triceps,
        "upper legs": .legs,
        "legs": .legs,
        "quads": .legs,
        "quadriceps": .legs,
        "hamstrings": .legs,
        "hamstring": .legs,
        "adductors": .legs,
        "abductors": .legs,
        "thighs": .legs,
        "thigh": .legs,
        "glutes": .glutes,
        "gluteus": .glutes,
        "gluteus maximus": .glutes,
        "hips": .glutes,
        "hip": .glutes,
        "abs": .core,
        "abdominals": .core,
        "waist": .core,
        "core": .core,
        "obliques": .core,
        "rectus abdominis": .core,
        "transverse abdominis": .core,
        "calves": .calves,
        "calf": .calves,
        "gastrocnemius": .calves,
        "soleus": .calves,
        "lower legs": .calves,
    ]
}

extension String {
    var normalizedExerciseToken: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

extension Sequence {
    func uniqued<ID: Hashable>(by keyPath: KeyPath<Element, ID>) -> [Element] {
        var seen = Set<ID>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
