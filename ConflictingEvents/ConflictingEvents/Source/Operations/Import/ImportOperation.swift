//
//  ImportOperation.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//
import Foundation
import Combine
import CoreData

final class ImportOperation: QueuedOperation {
    var saveFinished: ((Error?) -> Void)?
    
    init(saveFinished: ((Error?) -> Void)?) {
        self.saveFinished = saveFinished
        super.init(priority: .high)
    }
    
    final override func main() {
        if let foundItems = readLocalFile(forName: "mock") {
            guard !isCancelled else {
                cancel()
                return
            }
            
            process(response: foundItems)
        }
    }
    
    private func process(response: [ImportEventModel]) {
        let taskContext = newTaskContext()
        taskContext.perform { [weak self] in
            guard let self = self else { return }
            let batchInsert = self.newBatchInsertRequest(with: response)
            var e: Error?
            do {
                try taskContext.execute(batchInsert)
                try taskContext.save()
            } catch {
                e = error
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.saveFinished?(e)
                self.completed()
            }
        }
    }
    
    private func newBatchInsertRequest(with response: [ImportEventModel]) -> NSBatchInsertRequest {
        let batchInsert: NSBatchInsertRequest
        // Provide one dictionary at a time when the block is called.
        var index = 0
        let total = response.count
        batchInsert = NSBatchInsertRequest(entityName: "Event", dictionaryHandler: { [unowned self] dictionary in
            guard index < total else { return true }
            guard !isCancelled else {
                cancel()
                return true
            }
            dictionary.addEntries(from: convert(model: response[index]))
            index += 1
            return false
        })
        batchInsert.resultType = .statusOnly
        return batchInsert
    }
    
    private func convert(model: ImportEventModel) -> [String: Any] {
        var returnVal = [String: Any]()
        let startDate = DateFormatter.dateFormatter.date(from: model.start) ?? Date()
        let sortIndexFilter = DateFormatter.sortIndexFormatter.string(from: startDate)
        
        returnVal["title"] = model.title
        returnVal["eventId"] = UUID()
        returnVal["start"] = startDate
        returnVal["end"] = DateFormatter.dateFormatter.date(from: model.end)
        returnVal["sortIndex"] = DateFormatter.sortIndexFormatter.date(from: sortIndexFilter)?.timeIntervalSince1970
        return returnVal
    }
    
    private func readLocalFile(forName name: String) -> [ImportEventModel]? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
            let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return try JSONDecoder().decode([ImportEventModel].self,from: jsonData)
            }
        } catch {
            // TODO: Could log the error if it wasnt a kata
        }
        return nil
    }
    
    //
    // When importing large amounts of data. Apple actually recommends setting up a new PersistentContainer
    // that is used specifically for the import. https://developer.apple.com/documentation/coredata/loading_and_displaying_a_large_data_feed
    //
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ConflictingEvents")
        
        if NSClassFromString("XCTest") != nil {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { storeDesription, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
    
        return container
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        return taskContext
    }
}
