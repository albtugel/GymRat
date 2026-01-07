//
//  Exercise.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var logs: [ExerciseLog] = []

    init(name: String) {
        self.name = name
    }
}
