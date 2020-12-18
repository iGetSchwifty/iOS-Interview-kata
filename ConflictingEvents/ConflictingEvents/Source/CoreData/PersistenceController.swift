//
//  PersistenceController.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//
import CoreData

struct PersistenceController {
    private static let shared = PersistenceController()
    private let container: NSPersistentContainer
    
    static var viewContext = PersistenceController.shared.container.viewContext

    static func newBackgroundContext() -> NSManagedObjectContext {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }

    fileprivate init() {
        container = NSPersistentContainer(name: "ConflictingEvents")
        
        if NSClassFromString("XCTest") != nil {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // let our view get the changes from the saved background contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static func clear() {
        // This is where we batch delete all of the entites on the background context
        // We then take those changes and merge them into the view context
        shared.container.managedObjectModel.entities.forEach {
            guard let name = $0.name else { return }

            let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: name)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            request.resultType = .resultTypeObjectIDs

            do {
                guard let req = try shared.container.persistentStoreCoordinator.execute(request, with: newBackgroundContext()) as? NSBatchDeleteResult else { return }

                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: [NSDeletedObjectsKey: req.result as? [NSManagedObjectID] ?? []],
                    into: [viewContext])
            }
            catch {
                print(error)
            }
        }
    }
}

