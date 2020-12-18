//
//  CheckConflictsOperationTests.swift
//  ConflictingEventsTests
//
//  Created by Jeffrey on 12/13/20.
//
import CoreData
import XCTest
@testable import ConflictingEvents

class CheckConflictsTests: XCTestCase {
    override func setUp() {
        removeItems()
    }
    
    override func tearDown() {
        removeItems()
    }
    
    func test_operation_noConflicts() {
        let context = PersistenceController.newBackgroundContext()
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \Event.sortIndex, ascending: true), NSSortDescriptor(keyPath: \Event.start, ascending: true)]
        
        let fetchedController: NSFetchedResultsController<Event> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        let controller = ResultsController()
        fetchedController.delegate = controller
        try? fetchedController.performFetch()

        let expectation = XCTestExpectation(description: "Mark items in CoreData as conflicted")
        
        context.performAndWait {
            let event = Event(entity: Event.entity(), insertInto: context)
            event.title = "Fake Title"
            event.eventId = UUID()
            event.start = Date(timeIntervalSince1970: 0)
            event.end = Date(timeIntervalSince1970: 42)
            event.sortIndex = 0
            
            let event2 = Event(entity: Event.entity(), insertInto: context)
            event2.title = "Fake Title"
            event2.eventId = UUID()
            event2.start = Date(timeIntervalSince1970: 70)
            event2.end = Date(timeIntervalSince1970: 88)
            event2.sortIndex = 70
            try? context.save()
        }
        
        controller.callback = { conflictCount in
            XCTAssertEqual(conflictCount, 0)
            expectation.fulfill()
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(CheckConflictsOperation())
        
        context.performAndWait {
            let event = Event(entity: Event.entity(), insertInto: context)
            event.title = "Fake Titleasdfasdfasdf"
            event.eventId = UUID()
            event.start = Date(timeIntervalSince1970: 110)
            event.end = Date(timeIntervalSince1970: 142)
            event.sortIndex = 0
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertEqual(queue.operationCount, 0)
    }
    
    func test_operation_hasOnlyOneConflicts() {
        let context = PersistenceController.newBackgroundContext()
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \Event.sortIndex, ascending: true), NSSortDescriptor(keyPath: \Event.start, ascending: true)]
        
        let fetchedController: NSFetchedResultsController<Event> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        let controller = ResultsController()
        fetchedController.delegate = controller
        try? fetchedController.performFetch()

        let expectation = XCTestExpectation(description: "Check for conflicts in CoreData")
        
        context.performAndWait {
            let event = Event(entity: Event.entity(), insertInto: context)
            event.title = "Fake Title"
            event.eventId = UUID()
            event.start = Date(timeIntervalSince1970: 0)
            event.end = Date(timeIntervalSince1970: 42)
            event.sortIndex = 0
            
            let event2 = Event(entity: Event.entity(), insertInto: context)
            event2.title = "Fake Title2"
            event2.eventId = UUID()
            event2.start = Date(timeIntervalSince1970: 70)
            event2.end = Date(timeIntervalSince1970: 88)
            event2.sortIndex = 70
            
            let event3 = Event(entity: Event.entity(), insertInto: context)
            event3.title = "Fake Title3"
            event3.eventId = UUID()
            event3.start = Date(timeIntervalSince1970: 0)
            event3.end = Date(timeIntervalSince1970: 40)
            event3.sortIndex = 0
            
            try? context.save()
        }
        
        controller.callback = { conflictCount in
            XCTAssertEqual(conflictCount, 2)
            expectation.fulfill()
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(CheckConflictsOperation())
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertEqual(queue.operationCount, 0)
    }
    
    func test_operation_hasOnlyTwoConflicts() {
        let context = PersistenceController.newBackgroundContext()
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \Event.sortIndex, ascending: true), NSSortDescriptor(keyPath: \Event.start, ascending: true)]
        
        let fetchedController: NSFetchedResultsController<Event> = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        let controller = ResultsController()
        fetchedController.delegate = controller
        try? fetchedController.performFetch()

        let expectation = XCTestExpectation(description: "Mark items in CoreData as conflicted")
        
        context.performAndWait {
            let event = Event(entity: Event.entity(), insertInto: context)
            event.title = "Fake Title"
            event.eventId = UUID()
            event.start = Date(timeIntervalSince1970: 0)
            event.end = Date(timeIntervalSince1970: 42)
            event.sortIndex = 0
            
            let event2 = Event(entity: Event.entity(), insertInto: context)
            event2.title = "Fake Title2"
            event2.eventId = UUID()
            event2.start = Date(timeIntervalSince1970: 70)
            event2.end = Date(timeIntervalSince1970: 88)
            event2.sortIndex = 70
            
            let event3 = Event(entity: Event.entity(), insertInto: context)
            event3.title = "Fake Title3"
            event3.eventId = UUID()
            event3.start = Date(timeIntervalSince1970: 0)
            event3.end = Date(timeIntervalSince1970: 41)
            event3.sortIndex = 0
            
            let event4 = Event(entity: Event.entity(), insertInto: context)
            event4.title = "Fake Title4"
            event4.eventId = UUID()
            event4.start = Date(timeIntervalSince1970: 70)
            event4.end = Date(timeIntervalSince1970: 89)
            event4.sortIndex = 70
            
            let event5 = Event(entity: Event.entity(), insertInto: context)
            event5.title = "Fake Title5"
            event5.eventId = UUID()
            event5.start = Date(timeIntervalSince1970: 170)
            event5.end = Date(timeIntervalSince1970: 188)
            event5.sortIndex = 170
            
            try? context.save()
        }
        
        controller.callback = { conflictCount in
            XCTAssertEqual(conflictCount, 4)
            expectation.fulfill()
        }
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(CheckConflictsOperation())
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertEqual(queue.operationCount, 0)
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

fileprivate class ResultsController: NSObject, NSFetchedResultsControllerDelegate {
    var callback: ((Int) -> Void)?
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {}
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let totalConflict = (controller.fetchedObjects as! [Event]).reduce(0) { (total, item) in
            return total + ((item.hasConflict) ? 1 : 0)
        }
        callback?(totalConflict)
    }
}
