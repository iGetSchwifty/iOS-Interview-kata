//
//  DateFormatter+CustomTests.swift
//  ConflictingEventsTests
//
//  Created by Jeffrey on 12/13/20.
//

import XCTest
@testable import ConflictingEvents

class DateFormatterCustomTests: XCTestCase {
    func test_dateFormatter_toString() {
        let res = DateFormatter.dateFormatter.string(from: Date(timeIntervalSince1970: 42))
        XCTAssertEqual(res, "December 31, 1969 7:00 PM")
    }
    
    
    func test_dateFormatter_toDate() {
        let res = DateFormatter.dateFormatter.date(from: "November 9, 2018 12:30 PM")
        XCTAssertEqual(res, Date(timeIntervalSince1970: 1541784600))
    }
    
    func test_sortIndexFormatter_toString() {
        let res = DateFormatter.sortIndexFormatter.string(from: Date(timeIntervalSince1970: 42))
        XCTAssertEqual(res, "12/31/69")
    }
    
    
    func test_sortIndexFormatter_toDate() {
        let res = DateFormatter.sortIndexFormatter.date(from: "1/31/90")
        XCTAssertEqual(res, Date(timeIntervalSince1970: 633762000))
    }
}
