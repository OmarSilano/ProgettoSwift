import Foundation
import CoreData

extension WorkoutDayDetail {
    
    // convenience init
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     workoutDay: WorkoutDay,
                     exercise: Exercise,
                     typology: Typology,
                     orderIndex: Int16) {
        self.init(context: context)
        self.id = id
        self.workoutDay = workoutDay
        self.exercise = exercise
        self.typology = typology
        self.orderIndex = orderIndex
    }
}
