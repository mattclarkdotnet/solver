import XCTest

final class SolverUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testImplementedFlowsRunInSingleAppSession() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_RESET_STATE")
        app.launch()

        assertNoSolverHeader(in: app)
        XCTAssertTrue(wordListPreferencesControl(in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(statusMenuControl(in: app).waitForExistence(timeout: 5))

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Start with a pattern"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "", to: "apple")
        XCTAssertTrue(app.staticTexts["No matches for apple"].waitForExistence(timeout: 5))
        XCTAssertEqual(activeWordListLabel(in: app), "Test")

        selectWordList(named: "English", in: app)
        XCTAssertTrue(app.otherElements["crossword-results-card"].waitForExistence(timeout: 5))
        XCTAssertEqual(activeWordListLabel(in: app), "English")

        selectWordList(named: "Test", in: app)
        XCTAssertTrue(app.staticTexts["No matches for apple"].waitForExistence(timeout: 5))
        XCTAssertEqual(activeWordListLabel(in: app), "Test")
        openSecondarySheet(named: "About", in: app)
        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()

        replaceText(in: patternField, from: "apple", to: "c?t")
        XCTAssertTrue(app.staticTexts["Cat"].waitForExistence(timeout: 5))
        app.staticTexts["Cat"].press(forDuration: 0.5)
        XCTAssertTrue(app.staticTexts["A small domesticated feline animal."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["feline"].waitForExistence(timeout: 5))
        app.buttons["Done"].tap()

        replaceText(in: patternField, from: "c?t", to: "p????? v????")
        XCTAssertTrue(app.staticTexts["Pancho Villa"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "p????? v????", to: "ice-")
        XCTAssertTrue(app.staticTexts["Fix the pattern first"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Patterns cannot end with a word break."].waitForExistence(timeout: 5))

        selectTool(named: "scrabble", in: app)
        assertNoSolverHeader(in: app)
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "ice-", to: "stare")
        XCTAssertTrue(app.staticTexts["Aster"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["scrabble-results-card"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "stare", to: "crat?")
        XCTAssertTrue(app.staticTexts["Crate"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["scrabble-results-card"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "crat?", to: "star")

        let otherLettersField = app.textFields["scrabble-other-letters-field"]
        XCTAssertTrue(otherLettersField.waitForExistence(timeout: 5))
        replaceText(in: otherLettersField, from: "", to: "e")
        app.swipeUp()
        XCTAssertTrue(app.otherElements["scrabble-results-card"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "star", to: "sta-re")
        XCTAssertTrue(app.staticTexts["Fix the Scrabble letters first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Scrabble search supports rack letters plus ? blank tiles only."].waitForExistence(timeout: 5)
        )

        selectTool(named: "anagramSolver", in: app)
        assertNoSolverHeader(in: app)
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "sta-re", to: "stare")
        XCTAssertTrue(app.staticTexts["Aster"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Rates"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "stare", to: "villap-ancho")
        XCTAssertTrue(app.staticTexts["Pancho Villa"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "villap-ancho", to: "st?re")
        XCTAssertTrue(app.staticTexts["Fix the input first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Anagram solving currently supports letters only, without wildcards."].waitForExistence(timeout: 5)
        )

        selectTool(named: "definitions", in: app)
        assertNoSolverHeader(in: app)
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "st?re", to: "solver")
        XCTAssertTrue(app.staticTexts["solver"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["SOL-vuhr"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["A person or thing that finds an answer to a problem or puzzle."].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "solver", to: "solv?r")
        XCTAssertTrue(app.staticTexts["Fix the lookup first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Definitions lookup supports literal words or phrases only, without wildcards or rack symbols."].waitForExistence(timeout: 5)
        )

        selectTool(named: "thesaurus", in: app)
        assertNoSolverHeader(in: app)
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "solv?r", to: "solver")
        XCTAssertTrue(app.staticTexts["solver"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["answerer"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "solver", to: "solv?r")
        XCTAssertTrue(app.staticTexts["Fix the lookup first"].waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts["Thesaurus lookup supports literal words or phrases only, without wildcards or rack symbols."].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    private func selectTool(named rawToolName: String, in app: XCUIApplication) {
        let selector = app.scrollViews["tool-selector"]
        XCTAssertTrue(selector.waitForExistence(timeout: 5))

        let button = app.buttons["tool-button-\(rawToolName)"]
        for _ in 0..<8 {
            if button.waitForExistence(timeout: 1), button.isHittable {
                button.tap()
                return
            }
            selector.swipeLeft()
        }

        for _ in 0..<8 {
            if button.waitForExistence(timeout: 1), button.isHittable {
                button.tap()
                return
            }
            selector.swipeRight()
        }

        XCTFail("Could not select tool \(rawToolName)")
    }

    @MainActor
    private func selectWordList(named name: String, in app: XCUIApplication) {
        let preferencesButton = wordListPreferencesControl(in: app)
        XCTAssertTrue(preferencesButton.waitForExistence(timeout: 5))
        preferencesButton.tap()

        let option = app.buttons[name]
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }

    @MainActor
    private func openSecondarySheet(named name: String, in app: XCUIApplication) {
        let menuButton = statusMenuControl(in: app)
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5))
        menuButton.tap()

        let option = app.buttons[name]
        XCTAssertTrue(option.waitForExistence(timeout: 5))
        option.tap()
    }

    @MainActor
    private func assertNoSolverHeader(in app: XCUIApplication) {
        XCTAssertFalse(app.navigationBars["Solver"].exists)
        XCTAssertFalse(app.staticTexts["Solver"].exists)
    }

    @MainActor
    private func wordListPreferencesControl(in app: XCUIApplication) -> XCUIElement {
        if app.buttons["word-list-preferences-button"].exists {
            return app.buttons["word-list-preferences-button"]
        }

        let visibleWordListButton = app.buttons.matching(
            NSPredicate(format: "label == 'Test' OR label == 'English'")
        ).firstMatch
        if visibleWordListButton.exists {
            return visibleWordListButton
        }

        return app.otherElements.matching(
            NSPredicate(format: "label == 'Word list'")
        ).firstMatch
    }

    @MainActor
    private func statusMenuControl(in app: XCUIApplication) -> XCUIElement {
        if app.buttons["secondary-actions-button"].exists {
            return app.buttons["secondary-actions-button"]
        }
        return app.buttons["More"]
    }

    @MainActor
    private func activeWordListLabel(in app: XCUIApplication) -> String? {
        let control = wordListPreferencesControl(in: app)
        if let value = control.value as? String, value.isEmpty == false {
            return value
        }

        let label = control.label
        if label == "Test" || label == "English" {
            return label
        }

        return nil
    }

    @MainActor
    private func replaceText(in field: XCUIElement, from oldValue: String, to newValue: String) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()

        if oldValue.isEmpty == false {
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: oldValue.count))
        }

        if newValue.isEmpty == false {
            field.typeText(newValue)
        }
    }
}
