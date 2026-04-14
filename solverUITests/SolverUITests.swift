import XCTest

final class SolverUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsFocusedCrosswordShell() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        XCTAssertTrue(app.textFields["pattern-field"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Start with a pattern"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["crossword-search-button"].exists)
    }

    @MainActor
    func testCrosswordResultsUpdateLiveWhileTyping() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("c?t")

        XCTAssertTrue(app.staticTexts["Cat"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testInvalidPatternShowsInlineGuidance() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("ice-")

        XCTAssertTrue(app.staticTexts["Fix the pattern first"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Patterns cannot end with a word break."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAnagramTabShowsLiveMatchesFromBundledTestData() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        app.tabBars.buttons["Anagram"].tap()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("stare")

        XCTAssertTrue(app.staticTexts["Aster"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rates"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAnagramTabRejectsWildcardInputInline() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        app.tabBars.buttons["Anagram"].tap()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("st?re")

        XCTAssertTrue(app.staticTexts["Fix the input first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Anagram solving currently supports letters only, without wildcards."].waitForExistence(timeout: 5)
        )
    }
}
