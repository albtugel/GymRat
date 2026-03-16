//
//  AccentColor.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

enum AccentColorOption: String, CaseIterable, Identifiable {
    case blue, green, orange, red, purple
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .purple: return .purple
        }
    }

    var title: String { rawValue.capitalized }
}


