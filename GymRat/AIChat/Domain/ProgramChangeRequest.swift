import Foundation

struct ProgramChangeRequest: Codable, Equatable {
    let programId: UUID?
    let actions: [ProgramChangeAction]
}

enum ProgramChangeAction: Codable, Equatable {
    case setDays([Int]) // 1=Mon ... 7=Sun
    case addExercise(String)
    case removeExercise(String)
    case reorderExercises([String])
    case setSets(exerciseName: String, sets: Int)

    private enum CodingKeys: String, CodingKey {
        case type
        case days
        case name
        case order
        case sets
    }

    private enum ActionType: String, Codable {
        case setDays
        case addExercise
        case removeExercise
        case reorderExercises
        case setSets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)
        switch type {
        case .setDays:
            let days = try container.decode([Int].self, forKey: .days)
            self = .setDays(days)
        case .addExercise:
            let name = try container.decode(String.self, forKey: .name)
            self = .addExercise(name)
        case .removeExercise:
            let name = try container.decode(String.self, forKey: .name)
            self = .removeExercise(name)
        case .reorderExercises:
            let order = try container.decode([String].self, forKey: .order)
            self = .reorderExercises(order)
        case .setSets:
            let name = try container.decode(String.self, forKey: .name)
            let sets = try container.decode(Int.self, forKey: .sets)
            self = .setSets(exerciseName: name, sets: sets)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .setDays(let days):
            try container.encode(ActionType.setDays, forKey: .type)
            try container.encode(days, forKey: .days)
        case .addExercise(let name):
            try container.encode(ActionType.addExercise, forKey: .type)
            try container.encode(name, forKey: .name)
        case .removeExercise(let name):
            try container.encode(ActionType.removeExercise, forKey: .type)
            try container.encode(name, forKey: .name)
        case .reorderExercises(let order):
            try container.encode(ActionType.reorderExercises, forKey: .type)
            try container.encode(order, forKey: .order)
        case .setSets(let name, let sets):
            try container.encode(ActionType.setSets, forKey: .type)
            try container.encode(name, forKey: .name)
            try container.encode(sets, forKey: .sets)
        }
    }
}
