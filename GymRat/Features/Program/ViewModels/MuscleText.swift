import Foundation

enum MuscleText {
    static func localizedLabel(for muscle: MuscleGroup) -> String {
        switch muscle {
        case .chest: return String(localized: "muscle_chest")
        case .back: return String(localized: "muscle_back")
        case .shoulders: return String(localized: "muscle_shoulders")
        case .biceps: return String(localized: "muscle_biceps")
        case .triceps: return String(localized: "muscle_triceps")
        case .legs: return String(localized: "muscle_legs")
        case .glutes: return String(localized: "muscle_glutes")
        case .core: return String(localized: "muscle_core")
        case .calves: return String(localized: "muscle_calves")
        }
    }
}
