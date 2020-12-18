//
//  ContentViewModel.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//
import Foundation
import Combine
import CoreData

class ContentViewModel: NSObject, ObservableObject {
    @Published var currentState: State = .initalize
    
    enum State: Equatable {
        static func == (lhs: ContentViewModel.State, rhs: ContentViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.initalize, .initalize):
                return true
            case (.load, .load):
                return true
            case (.remove, .remove):
                return true
            case (.results(_), .results(_)):
                // As far as this kata goes. This is fine.
                // However, ideally we would implement the == check on the left and right part of this enum
                return true
            default:
                return false
            }
        }
        
        case initalize
        case load
        case results(events: [[UIEventItem]])
        case remove
    }
    
    fileprivate var importQueue: OperationQueue = {
        let returnVal = OperationQueue()
        returnVal.qualityOfService = .background
        returnVal.maxConcurrentOperationCount = 1
        return returnVal
    }()
    
    private var controller: NSFetchedResultsController<Event>?
    
    // Because NSBatchInsertRequest bypasses the context and doesn’t trigger NSManagedObjectContextDidSavenotification
    // Reset the context and re-fetch data from the store.
    private var needsToRefreshContext = false
    
    override init() {
        super.init()
        refreshFromCoreData()
    }
    
    public func handle(newState: State) {
        switch newState {
        case .load:
            load()
        case .remove:
            delete()
        default: break
        }
    }
    
    private func delete() {
        PersistenceController.clear()
        currentState = .remove
    }

    private func load() {
        if case .results = currentState { return }
        
        currentState = .load
        needsToRefreshContext = true
        importQueue.addOperation(ImportOperation(saveFinished: { [weak self] error in
            guard let self = self else { return }
            if error != nil { return }
            
            self.resetAndFetch()
        }))
        importQueue.addOperation(CheckConflictsOperation())
    }
    
    private func refreshFromCoreData() {
        let context = PersistenceController.viewContext
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Event.sortIndex, ascending: true),
                                   NSSortDescriptor(keyPath: \Event.start, ascending: true)]
        
        self.controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.controller?.delegate = self
        fetch()
    }
    
    private func resetAndFetch() {
        if self.needsToRefreshContext {
            self.needsToRefreshContext = false
            PersistenceController.viewContext.reset()
            fetch()
        }
    }
    
    private func fetch() {
        do {
            try self.controller?.performFetch()
        } catch let error {
            print(error)
        }
        groupAndUpdateView()
    }
    
    private func groupAndUpdateView() {
        let fetchedObjects: [UIEventItem] = self.controller?.fetchedObjects?.map({ UIEventItem.make(fromEvent: $0) }) ?? []
        
        let fetchedResultsCount = fetchedObjects.count
        if fetchedResultsCount > 0 {
            currentState = .load
        }
        
        group(items: fetchedObjects) { [weak self] results in
            guard results.count > 0 else { return }
            self?.currentState = .results(events: results)
        }
    }
    
    private func group(items: [UIEventItem], callback: @escaping ([[UIEventItem]]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var currentEventQueue = [UIEventItem]()
            var results = [[UIEventItem]]()
            if var currentSortIndex = items.first?.sortIndex  {
                for event in items {
                    if event.sortIndex != currentSortIndex {
                        results.append(currentEventQueue)
                        currentEventQueue.removeAll()
                        currentSortIndex = event.sortIndex
                    }
                    currentEventQueue.append(event)
                }
                
                if currentEventQueue.count != 0 {
                    results.append(currentEventQueue)
                    currentEventQueue.removeAll()
                }
            }
            DispatchQueue.main.async {
                callback(results)
            }
        }
    }
}

extension ContentViewModel: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        groupAndUpdateView()
    }
}
