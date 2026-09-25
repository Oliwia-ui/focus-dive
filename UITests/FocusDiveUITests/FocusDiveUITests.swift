import XCTest

final class FocusDiveUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["FOCUS_DIVE_UI_TESTING"] = "1"
        app.launch()
    }

    func testStartPauseAndResetControls() {
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
