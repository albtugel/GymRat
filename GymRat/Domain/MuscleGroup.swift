//
//  MuscleGroup.swift
//  GymRat
//
//  Created by Alik on 3/19/26.
//

import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case legs
    case glutes
    case core
    case calves

    var id: String { rawValue }

    var localizedLabel: String {
        switch self {
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
