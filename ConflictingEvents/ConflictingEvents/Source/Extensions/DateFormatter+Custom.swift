//
//  DateFormatter+Custom.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//
import Foundation

extension DateFormatter {
    // Used to convert dates around from the mock json format
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()
    
    // Used to convert a date to the CoreData sort index
    static let sortIndexFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "EST")
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
}
