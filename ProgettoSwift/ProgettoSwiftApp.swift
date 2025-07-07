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
}
 */

@main
struct ProgettoSwiftApp: App {
    
    let persistenceController = PersistenceController.shared
    
    /*
    let workouts :[Workout] = [
        Workout(name: "PIRAMIDALE A", days: "X Days", weeks: "A Weeks"),
        Workout(name: "PIRAMIDALE INVERSO B", days: "Y Days", weeks: "B Weeks"),
        Workout(name: "10X4 C", days: "Z Days", weeks: "C Weeks"),
        Workout(name: "8X4 D", days: "W Days", weeks: "D Weeks"),
        Workout(name: "UTENTE 1", days: "K Days", weeks: "E Weeks"),
        Workout(name: "UTENTE 2", days: "H Days", weeks: "F Weeks")
    ]
*/
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\EnvironmentValues.managedObjectContext, persistenceController.container.viewContext)

        }
    }
}
