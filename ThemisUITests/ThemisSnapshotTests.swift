//
//  ThemisSnapshotTests.swift
//  ThemisUITests
//
//  Created by Anian Schleyer on 08.06.24.
//

import XCTest

class ThemisSnapshotTests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        setupSnapshot(app)
    }
    
    @MainActor
    func testTakeScreenshots() {
        app.launch()

        snapshot("01Dashboard")
        
        // Navigate to exercise
        app.staticTexts["SwiftUI Button Style"].tap()
        
        snapshot("02ExerciseDetailView")
        
        // Navigate to Assessment View
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts["Submission #1"].tap()
        collectionViewsQuery.staticTexts["code.swift"].tap()
        
        snapshot("03AssessmentView")
        
    }
}
