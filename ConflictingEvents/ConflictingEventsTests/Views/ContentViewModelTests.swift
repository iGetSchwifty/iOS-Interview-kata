//
//  ContentViewModelTests.swift
//  ConflictingEventsTests
//
//  Created by Jeffrey on 12/13/20.
//
import Combine
import CoreData
import XCTest
@testable import ConflictingEvents

class ContentViewModelTests: XCTestCase {
    override func setUp() {
        removeItems()
    }
    
    func test_currentState_init() {
        XCTAssertEqual(ContentViewModel().currentState, .initalize)
    }
    
    func test_currentState_load() {
        let viewModel = ContentViewModel()
        viewModel.handle(newState: .load)
        XCTAssertEqual(viewModel.currentState, .load)
    }
    
    func test_currentState_results() {
        let expectation = XCTestExpectation(description: "Import items into CoreData")
        let disposeBag: AnyCancellable
        let context = PersistenceController.newBackgroundContext()
        context.performAndWait {
            let event = Event(entity: Event.entity(), insertInto: context)
            event.title = "Fake Title"
            event.eventId = UUID()
            event.start = Date(timeIntervalSince1970: 110)
            event.end = Date(timeIntervalSince1970: 142)
            event.sortIndex = 0
            try? context.save()
        }
        let viewModel = ContentViewModel()
        viewModel.handle(newState: .load)
        disposeBag = viewModel.$currentState.sink { (state: ContentViewModel.State) in
            switch state {
            case .results(let events):
                XCTAssertEqual(events.count, 1)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 5.0)
        disposeBag.cancel()
    }
    
    func test_currentState_remove() {
        let viewModel = ContentViewModel()
        viewModel.handle(newState: .remove)
        XCTAssertEqual(viewModel.currentState, .remove)
    }
    
    private func removeItems() {
        let context = PersistenceController.newBackgroundContext()
        context.performAndWait {
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            let results = try? context.fetch(request)
            results?.forEach({ item in
                context.delete(item)
            })
            try? context.save()
        }
    }
}
