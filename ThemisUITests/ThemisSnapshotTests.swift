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
        XCUIDevice.shared.orientation = .landscapeLeft
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
        
        // Add inline feedback
        let enterFeedback = app.textViews["Enter your feedback here"]
        while !enterFeedback.exists {
            app.textViews["        .background(isEnabled ? color : Color(.systemGray))"].swipeLeft(velocity: .slow)
        }
        enterFeedback.tap()
        enterFeedback.typeText("Good job!")
        app.pickerWheels["0.0"].swipeDown(velocity: .slow)
        app.buttons["SaveAssessment"].tap()
        
        // Open correction tab with feedback
        app.staticTexts["Correction"].tap()
        app.buttons["Feedback"].tap()
        
        snapshot("03AssessmentView")
    }

    // Opening Text assessment in separate test so we can skip navigating back
    @MainActor
    func testTakeScreenshotTextAssessment() {
        app.launch()

        // Navigate to text exercise
        app.scrollViews.otherElements.images["font-solid"].tap()
        
        app.navigationBars.element.buttons["Start Assessment"].tap()
        
        // Open feedback in right pane
        app.buttons["Feedback"].tap()
        
        let submission = app.textViews.textViews.element
        
        // Add inline feedback
        let enterFeedback = app.textViews["Enter your feedback here"]
        while !enterFeedback.exists {
            submission.swipeLeft(velocity: .fast)
        }
        enterFeedback.tap()
        enterFeedback.typeText("Good job!")
        app.pickerWheels["0.0"].swipeDown(velocity: .slow)
        app.buttons["SaveAssessment"].tap()
        
        snapshot("04AssessmentView")
    }
}
