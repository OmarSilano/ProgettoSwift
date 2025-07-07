//
//  Workout+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Workout {
    
    var difficultyEnum: Difficulty? {
            get {
                guard let rawValue = difficulty else { return nil }
                return Difficulty(rawValue: rawValue)
            }
            set {
                difficulty = newValue?.rawValue
            }
        }
    
    // Default paths se nil
    var safeImagePath: String {
        pathToImage ?? "default_image"
    }
    
    // Costruttore custom
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     weeks: Int16,
                     imagePath: String? = nil,
                     difficulty: Difficulty? = nil) {
        
        self.init(context: context)
        self.id = id
        self.name = name
        self.weeks = weeks
        self.pathToImage = imagePath
        self.difficultyEnum = difficulty

        // Calcola i giorni in base alla relazione 1-N con WorkoutDay
        self.days = Int16(self.workoutDay?.count ?? 0)
    }

    
}

