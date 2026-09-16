import Foundation
import Testing
@testable import GymRat

struct ExerciseEntryDraftTests {

    @Test func showingADayFillsTheFieldsAndSizesThemToItsSets() {
        var draft = Self.makeDraft(defaultSets: 3)

        draft.show(
            day: Self.today,
            current: ExerciseLogValues(repsBySet: [10, 8], weightsBySet: [60, 60], durationsBySet: [0, 0]),
            previous: ExerciseLogValues(repsBySet: [12], weightsBySet: [50], durationsBySet: [0])
        )

        #expect(draft.setsCountText == "2")
        #expect(draft.current.reps == ["10", "8"])
        #expect(draft.current.weights == ["60", "60"])
        #expect(draft.previous.reps == ["12", ""])
        #expect(!draft.hasUnsavedChanges)
    }

    @Test func emptyDayUsesThePreviousDaysSetCountOrTheDefault() {
        var draft = Self.makeDraft(defaultSets: 3)
        draft.show(day: Self.today, current: nil, previous: ExerciseLogValues(repsBySet: [1, 1, 1, 1], weightsBySet: [0, 0, 0, 0], durationsBySet: [0, 0, 0, 0]))
        #expect(draft.setsCountText == "4")
        #expect(draft.current.reps == ["", "", "", ""])

        draft.show(day: Self.today, current: nil, previous: nil)
        #expect(draft.setsCountText == "3")
    }

    @Test func editingMarksTheDraftDirtyForTheShownDay() {
        var draft = Self.makeDraft(defaultSets: 3)
        draft.show(day: Self.today, current: nil, previous: nil)

        draft.updateReps("10", at: 0)

        #expect(draft.hasUnsavedChanges)
        #expect(draft.editSessionDate == Self.today)
        #expect(draft.values.repsBySet == [10, 0, 0])
    }

    @Test func changingTheSetCountResizesTheColumns() {
        var draft = Self.makeDraft(defaultSets: 3)
        draft.show(day: Self.today, current: nil, previous: nil)
        draft.updateReps("5", at: 2)

        draft.updateSetsCount("2")
        #expect(draft.current.reps == ["", ""])
        #expect(draft.setsEdited)

        draft.updateSetsCount("")
        #expect(draft.setsCountText == "")
        #expect(draft.setsCount == 3)
    }

    @Test func checkoutHandsOutTheEntriesAndMarksTheDraftClean() {
        var draft = Self.makeDraft(defaultSets: 2)
        draft.show(day: Self.today, current: nil, previous: nil)
        draft.updateReps("8", at: 0)
        draft.updateWeight("40", at: 0)

        let checkout = draft.checkout()

        #expect(checkout?.date == Self.today)
        #expect(checkout?.values == ExerciseLogValues(repsBySet: [8, 0], weightsBySet: [40, 0], durationsBySet: [0, 0]))
        #expect(checkout?.setsEdited == false)
        #expect(!draft.hasUnsavedChanges)
        #expect(draft.checkout() == nil)
    }

    @Test func failedSaveIsParkedAndRestoredWhenTheDayIsShownAgain() throws {
        var draft = Self.makeDraft(defaultSets: 2)
        draft.show(day: Self.today, current: nil, previous: nil)
        draft.updateReps("8", at: 0)
        let checkout = try #require(draft.checkout())

        draft.markSaveFailed(checkout)
        #expect(draft.hasUnsavedChanges)

        draft.show(day: Self.tomorrow, current: nil, previous: nil)
        #expect(draft.current.reps == ["", ""])
        #expect(draft.pendingSave != nil)

        draft.show(day: Self.today, current: nil, previous: nil)
        #expect(draft.current.reps == ["8", ""])
        #expect(draft.pendingSave == nil)
        #expect(draft.isDirty)
        #expect(draft.editSessionDate == Self.today)
    }

    @Test func aNewerSaveForTheSameDayClearsTheParkedOne() throws {
        var draft = Self.makeDraft(defaultSets: 1)
        draft.show(day: Self.today, current: nil, previous: nil)
        draft.updateReps("8", at: 0)
        let failed = try #require(draft.checkout())
        draft.markSaveFailed(failed)
        draft.updateReps("9", at: 0)

        let retried = try #require(draft.checkout())
        draft.markSaved(retried)

        #expect(draft.pendingSave == nil)
        #expect(!draft.hasUnsavedChanges)
    }

    private static let today = Date().startOfDay
    private static var tomorrow: Date { AppCalendar.calendar.date(byAdding: .day, value: 1, to: today) ?? today }

    private static func makeDraft(defaultSets: Int) -> ExerciseEntryDraft {
        let defaults = UserDefaults(suiteName: "ExerciseEntryDraftTests-\(UUID().uuidString)") ?? .standard
        let formatter = ExerciseEntryFormatter(units: Units(defaults: defaults), isCardio: false)
        return ExerciseEntryDraft(day: today, defaultSets: defaultSets, formatter: formatter)
    }
}
