import XCTest

final class SolverUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func openOverflowTab(named name: String, in app: XCUIApplication) {
        app.tabBars.buttons["More"].tap()
        XCTAssertTrue(app.tables.staticTexts[name].waitForExistence(timeout: 5))
        app.tables.staticTexts[name].tap()
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

    @MainActor
    func testScrabbleTabShowsSubsetMatchesFromRackTiles() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        app.tabBars.buttons["Scrabble"].tap()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("stare")

        XCTAssertTrue(app.staticTexts["Arts"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Star"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Art"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testScrabbleTabUsesBlankTilesInline() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        app.tabBars.buttons["Scrabble"].tap()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("crat?")

        XCTAssertTrue(app.staticTexts["Crate"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Trace"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testScrabbleTabRejectsUnsupportedRackInputInline() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        app.tabBars.buttons["Scrabble"].tap()

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("sta-re")

        XCTAssertTrue(app.staticTexts["Fix the rack first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Scrabble search supports rack letters plus ? blank tiles only."].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testDefinitionsTabShowsBundledDefinition() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        openOverflowTab(named: "Define", in: app)

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("solver")

        XCTAssertTrue(app.staticTexts["solver"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["SOL-vuhr"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["A person or thing that finds an answer to a problem or puzzle."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDefinitionsTabRejectsWildcardLookupInputInline() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        openOverflowTab(named: "Define", in: app)

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        patternField.tap()
        patternField.typeText("solv?r")

        XCTAssertTrue(app.staticTexts["Fix the lookup first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Definitions lookup supports literal words or phrases only, without wildcards or rack symbols."].waitForExistence(timeout: 5)
        )
    }
}
