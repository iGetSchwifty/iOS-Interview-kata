//
//  CheckConflictsOperation.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//

import Combine
import CoreData

final class CheckConflictsOperation: QueuedOperation {
    init() {
        super.init(priority: .normal)
    }
    
    final override func main() {
        checkForConflicts()
    }

    private func checkForConflicts() {
        let context = PersistenceController.newBackgroundContext()
        context.perform { [weak self] in
            guard let self = self else { return }
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            request.sortDescriptors = [ NSSortDescriptor(keyPath: \Event.sortIndex, ascending: true), NSSortDescriptor(keyPath: \Event.start, ascending: true)]
            do {
                let results = try context.fetch(request)
                
                self.handleSearch(results)
                try context.save()
            } catch {
                // TODO: Log it if it wasnt a kata
            }
            
            self.completed()
        }
    }
    
    private func handleSearch(_ results: [Event]) {
        var queue = Heap { (left: Event, right: Event) -> Bool in
            guard let first = left.start else { return false }
            guard let second = right.start else { return false }
            return first < second
        }
        
        for event in results {
            // Could handle edge cases better here...
            while(!queue.isEmpty && (queue.peek()?.end ?? Date()) < (event.start ?? Date())) {
                let _ = queue.remove()
            }
            
            if let currentEvent = queue.peek() {
                let overlap = datesOverlap(first: currentEvent, second: event)
                currentEvent.hasConflict = overlap
                event.hasConflict = overlap
            }
            
            queue.insert(event)
        }
    }
    
    private func datesOverlap(first: Event, second: Event) -> Bool {
        guard let firstStart = first.start else { return false }
        guard let secondStart = second.start else { return false }
        guard let firstEnd = first.end else { return false }
        guard let secondEnd = second.end else { return false }
        
        return !(firstEnd <= secondStart || firstStart >= secondEnd)
    }
}
