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
        self.category = category?.rawValue
        self.days = Int16(self.workoutDay?.count ?? 0)
    }
    
    
    func toPlainText() -> String {
        var txt = "🏋️ WORKOUT: \(name ?? "Unnamed")\n"
        txt += "Weeks: \(weeks)\n"
        txt += "Days: \(days)\n\n"
        
        let workoutDays = (workoutDay?.allObjects as? [WorkoutDay]) ?? []
        for day in workoutDays.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) {
            txt += day.toPlainText()
            txt += "\n"
        }
        
        return txt
    }
    
    
}

