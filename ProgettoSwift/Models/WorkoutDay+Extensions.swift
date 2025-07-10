//
//  WorkoutDay.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension WorkoutDay {
    
    // muscles come array di stringhe, con default empty array se nil
    var musclesList: [MuscleGroup] {
        get {
            (muscles as? [String])?.compactMap { MuscleGroup(rawValue: $0) } ?? []
        }
        set {
            muscles = newValue.map { $0.rawValue } as NSObject
        }
    }

    
    // convenience init
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     isCompleted: Bool = false,
                     muscles: [MuscleGroup] = [],
                     workout: Workout) {
        self.init(context: context)
        self.id = id
        self.isCompleted = isCompleted
        self.musclesList = muscles
        self.workout = workout
    }
}

