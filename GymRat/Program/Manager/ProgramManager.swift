import Foundation
import SwiftData
import SwiftUI

final class ProgramManager: ObservableObject {

    static let shared = ProgramManager()

    @Published var programs: [ProgramModel] = []
    @Published var customPrograms: [ProgramModel] = []
    @Published var dayPrograms: [Date: [ProgramModel]] = [:]

    private init() {}

    func programs(for date: Date) -> [ProgramModel] {
        guard let weekday = ProgramWeekDay.from(date: date) else { return [] }
        return customPrograms.filter { $0.weekdays.contains(weekday) }
    }
}
