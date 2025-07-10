//
//  WorkoutDayDetail+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 10/07/25.
//
import Foundation
import CoreData

extension WorkoutDayDetail {
    
    // convenience init
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     workoutDay: WorkoutDay,
                     exercise: Exercise,
                     typology: Typology) {
        self.init(context: context)
        self.id = id
        self.workoutDay = workoutDay
        self.exercise = exercise
        self.typology = typology
    }
}

