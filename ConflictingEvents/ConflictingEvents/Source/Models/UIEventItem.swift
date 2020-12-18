//
//  UIEventItem.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/13/20.
//

import Foundation

//
//  Used to display CoreData Event objects to the view.
//  Useful if we fetch the objects on the background context
//  In order to not block the main thread when any sorting or grouping occurs
//
struct UIEventItem {
    var title: String?
    var start: Date?
    var end: Date?
    var eventId: UUID?
    var hasConflict: Bool
    var sortIndex: Int64
    
    static func make(fromEvent event: Event) -> UIEventItem {
        return UIEventItem(title: event.title,
                           start: event.start,
                           end: event.end,
                           eventId: event.eventId,
                           hasConflict: event.hasConflict,
                           sortIndex: event.sortIndex)
    }
}
