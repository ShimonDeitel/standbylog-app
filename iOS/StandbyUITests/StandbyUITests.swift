import XCTest

final class StandbyUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddItemFlow() {
        app.buttons["addButton"].tap()
        let field1 = app.textFields["field1TextField"]
        XCTAssertTrue(field1.waitForExistence(timeout: 3))
        field1.tap()
        field1.typeText("UI Test Entry")
        app.buttons["saveItemButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 3))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<40 {
            app.buttons["addButton"].tap()
            let field1 = app.textFields["field1TextField"]
            if !field1.waitForExistence(timeout: 2) { break }
            field1.tap()
            field1.typeText("Entry \(i)")
            app.buttons["saveItemButton"].tap()
            if app.buttons["paywallPurchaseButton"].exists {
                break
            }
        }
        XCTAssertTrue(app.buttons["paywallPurchaseButton"].waitForExistence(timeout: 3))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addButton"].tap()
        let field1 = app.textFields["field1TextField"]
        XCTAssertTrue(field1.waitForExistence(timeout: 3))
        field1.tap()
        field1.typeText("Dismiss test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Callout count"].tap()
        XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 1))
    }

    func testSettingsSheetOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 3))
        app.buttons["settingsDoneButton"].tap()
    }
}
