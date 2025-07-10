//
//  Workout+Extensions.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension Workout {
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     weeks: Int16,
                     imagePath: String?,
                     difficulty: Difficulty? = Difficulty.beginner,
                     category: Category? = nil,
                     isSaved: Bool = false) {
        
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.weeks = weeks
        self.pathToImage = imagePath
        self.difficulty = difficulty?.rawValue
        self.isSaved = isSaved
        self.category = category
    }

}

