//
//  UIEventItemTests.swift
//  ConflictingEventsTests
//
//  Created by Tacenda on 12/15/20.
//

import XCTest
@testable import ConflictingEvents

class UIEventItemTests: XCTestCase {
    func test_make() {
        let context = PersistenceController.newBackgroundContext()
        var madeObject: UIEventItem?
        let testUUID = UUID()
        context.performAndWait {
            let event = Event(entity: Event.entity(), insertInto: context)
            event.title = "Fake Title Test"
            event.eventId = testUUID
            event.start = Date(timeIntervalSince1970: 0)
            event.end = Date(timeIntervalSince1970: 42)
            event.sortIndex = 0
            event.hasConflict = true
            madeObject = UIEventItem.make(fromEvent: event)
        }
        XCTAssertEqual(madeObject?.title, "Fake Title Test")
        XCTAssertEqual(madeObject?.eventId, testUUID)
        XCTAssertEqual(madeObject?.start, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(madeObject?.end, Date(timeIntervalSince1970: 42))
        XCTAssertEqual(madeObject?.sortIndex, 0)
        XCTAssertEqual(madeObject?.hasConflict, true)
    }
}
