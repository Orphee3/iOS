//
//  UITests.swift
//  UITests
//
//  Created by John Bobington on 25/03/2016.
//  Copyright © 2016 __ORPHEE__. All rights reserved.
//

import XCTest

class UItests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {

        app.tabBars.buttons["More"].tap()
        app.staticTexts["Player"].tap()
        app.buttons["play"].tap()

        for _ in 0..<50 {
            let alert = app.alerts["Le lecteur a rencontré l'erreur suivante:"]
            expectationForPredicate(NSPredicate(format: "exists == true"), evaluatedWithObject: alert, handler: nil)

            waitForExpectationsWithTimeout(2, handler: nil)
            XCTAssert(alert.exists)
            print(alert.staticTexts.allElementsBoundByIndex.debugDescription)
            XCTAssert(alert.staticTexts["Impossible de charger 4 des 4 instruments."].exists)
            let okButton = alert.collectionViews.buttons["Ok"]
            okButton.tap()
            app.buttons["Button"].tap()
            app.buttons["pause"].tap()
        }
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
