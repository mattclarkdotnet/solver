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

        let patternField = app.textFields["pattern-field"]
        XCTAssertTrue(patternField.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Start with a pattern"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "", to: "c?t")
        XCTAssertTrue(app.staticTexts["Cat"].waitForExistence(timeout: 5))

        replaceText(in: patternField, from: "c?t", to: "ice-")
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

        replaceText(in: patternField, from: "stare", to: "st?re")
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
    private func assertNoSolverHeader(in app: XCUIApplication) {
        XCTAssertFalse(app.navigationBars["Solver"].exists)
        XCTAssertFalse(app.staticTexts["Solver"].exists)
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
