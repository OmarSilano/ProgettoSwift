//
//  WorkoutDayCompleted+Etensions.swift
//  ProgettoSwift
//
//  Created by Studente on 15/07/25.
//
import Foundation
import CoreData

extension WorkoutDayCompleted {
    
    /// Convenience initializer per creare una nuova istanza
    convenience init(context: NSManagedObjectContext,
                     workoutDay: WorkoutDay,
                     date: Date) {
        self.init(context: context)
        self.workoutDay = workoutDay
        self.date = date
    }
}
