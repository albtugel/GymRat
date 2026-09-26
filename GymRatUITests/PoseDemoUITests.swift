import XCTest

final class PoseDemoUITests: XCTestCase {
    @MainActor
    func testPhotoPickerIsVisibleAndOpens() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        app.buttons["settingsButton"].tap()
        let link = app.buttons["poseDemoLink"]
        for _ in 0..<5 {
            if link.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        let picker = app.buttons["posePhotoPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        XCTAssertTrue(picker.isHittable)
        let camera = app.buttons["poseCameraButton"]
        XCTAssertTrue(camera.exists)
        XCTAssertEqual(picker.frame.height, camera.frame.height, accuracy: 1)
        picker.tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10))
    }
}
