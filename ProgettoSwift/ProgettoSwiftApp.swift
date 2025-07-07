//
//  ProgettoSwiftApp.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let days: String
    let weeks: String
    let difficulty: String      //sarà enum
}

@main
struct ProgettoSwiftApp: App {
    let workouts :[Workout] = [
        Workout(name: "PIRAMIDALE A", days: "X", weeks: "A", difficulty: "Beginner"),
        Workout(name: "PIRAMIDALE INVERSO B", days: "Y", weeks: "B", difficulty: "Intermediate"),
        Workout(name: "10X4", days: "Z", weeks: "C", difficulty: "Advanced"),
        Workout(name: "8X4", days: "W", weeks: "D", difficulty: "Advanced"),
        Workout(name: "UTENTE 1", days: "K", weeks: "E", difficulty: "Beginner"),
        Workout(name: "UTENTE 2", days: "H", weeks: "F", difficulty: "Intermediate")
    ]

    
    var body: some Scene {
        WindowGroup {
            ContentView(workouts: workouts)
        }
    }
}
