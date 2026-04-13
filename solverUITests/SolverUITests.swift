import XCTest

final class SolverUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCrosswordSearchShowsBundledMatches() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("c?t\n")

        let searchButton = app.buttons["crossword-search-button"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5))
        searchButton.tap()

        XCTAssertTrue(app.staticTexts["Cat"].waitForExistence(timeout: 5))
    }
}
