//
//  AppDelegate.swift
//  ConflictingEvents
//
//  Created by Jeffrey on 12/12/20.
//
import SwiftUI

//
//  The entry point into the application.
//
@main
struct AppDelegate: App {
    let viewContext = PersistenceController.viewContext
    var body: some Scene {
        WindowGroup {
            // We dont want to show our apps view if we are running our unit tests.
            switch NSClassFromString("XCTest") {
            case nil:
                ContentView()
            default:
                Text("Testing...")
            }
        }
    }
}
