//
//  ImportOperationTests.swift
//  ConflictingEventsTests
//
//  Created by Jeffrey on 12/13/20.
//
import CoreData
import XCTest
@testable import ConflictingEvents

class ImportOperationTests: XCTestCase {
    func test_operation() {
        let expectation = XCTestExpectation(description: "Import items into CoreData")
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(ImportOperation(saveFinished: { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }))
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(queue.operationCount, 0)
    }
}
