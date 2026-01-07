//
//  WorkoutSession.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var date: Date
    var exercises: [Exercise] = []

    init(date: Date) {
        self.date = date
    }
}
