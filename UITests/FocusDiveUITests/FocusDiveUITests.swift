import XCTest

final class FocusDiveUITests: XCTestCase {
    @MainActor
    func testStartPauseAndResetControls() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["FOCUS_DIVE_UI_TESTING"] = "1"
        app.launch()

        let primary = app.buttons["primary-timer-control"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        XCTAssertEqual(primary.label, "Start focus timer")

        primary.click()
        XCTAssertEqual(primary.label, "Pause focus timer")

        app.buttons["reset-timer-control"].click()
        XCTAssertEqual(primary.label, "Start focus timer")
        XCTAssertTrue(app.staticTexts["timer-display"].label.contains("25:00"))
    }
}
