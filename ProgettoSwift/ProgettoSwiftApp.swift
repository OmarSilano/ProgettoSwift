//
//  ProgettoSwiftApp.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
/*
struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let days: String
    let weeks: String
    let difficulty: String      //sarà enum
}
 */

@main
struct ProgettoSwiftApp: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\EnvironmentValues.managedObjectContext, persistenceController.container.viewContext)

        }
    }
}
