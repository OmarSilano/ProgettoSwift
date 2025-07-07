//
//  Workout+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Workout {
    
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext,
                     name: String,
                     weeks: Int16,
                     imagePath: String?,
                     difficulty: Difficulty) {
        
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.weeks = weeks
        self.pathToImage = imagePath
        self.difficulty = difficulty.rawValue
    }

    // Optional: computed property to access the enum safely
    var difficultyLevel: Difficulty? {
        get { Difficulty(rawValue: difficulty ?? "") }
        set { difficulty = newValue?.rawValue }
    }
}

