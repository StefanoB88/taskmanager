//
//  TaskManagerUITests.swift
//  TaskManagerUITests
//
//  Created by Stefano on 11.03.25.
//

import XCTest

final class TaskManagerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testAddTask() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(15)
        
        createTask(app: app, title: "New Test Task", description: "This is a test task description.")

        let taskCell = app.staticTexts["New Test Task"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 5), "The task should appear in the task list")
    }
    
    @MainActor
    func testSort() throws {
        let app = XCUIApplication()
        app.launch()
        
        sleep(15)
        // Creazione di task con titoli variabili
        let taskTitles = ["Zebra Task", "Apple Task", "Middle Task"]
        for title in taskTitles {
            createTask(app: app, title: title)
        }
        
        let sortButton = app.buttons["sortTaskButton"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5), "Sort Task button should exist")
        sortButton.tap()
        
        let sortAlphabeticallyButton = app.sheets.firstMatch.buttons["Alphabetically"]
        XCTAssertTrue(sortAlphabeticallyButton.waitForExistence(timeout: 5), "The button to sort alphabetically should exist")
        sortAlphabeticallyButton.tap()
        
        let taskCells = app.tables.cells.allElementsBoundByIndex.compactMap { $0.staticTexts.firstMatch.label }

        XCTAssertEqual(taskCells, taskCells.sorted(), "Tasks should be sorted alphabetically")
    }
    
    private func createTask(app: XCUIApplication, title: String, description: String = "") {
        let addTaskButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 5), "Add Task button should exist")
        addTaskButton.tap()
        
        let titleTextField = app.textFields["addTaskTitle"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 5), "Title text field should exist")
        titleTextField.tap()
        titleTextField.typeText(title)
        
        if !description.isEmpty {
            let descriptionTextField = app.textFields["addTaskDescription"]
            XCTAssertTrue(descriptionTextField.waitForExistence(timeout: 5), "Description text field should exist")
            descriptionTextField.tap()
            descriptionTextField.typeText(description)
        }
        
        let saveButton = app.buttons["saveTaskButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save Task button should exist")
        saveButton.tap()
    }
}
