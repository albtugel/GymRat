import Foundation

struct ProgramTemplate {

    static let templates: [ProgramModel] = [
        ProgramModel(name: String(localized: "program_type_strength"), type: .strength),
        ProgramModel(name: String(localized: "program_type_cardio"), type: .cardio),
        ProgramModel(name: String(localized: "program_type_crossfit"), type: .crossfit)
    ]
}
