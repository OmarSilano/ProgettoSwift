//
//  WorkoutDayManager.swift
//  ProgettoSwift
//
//  Created by Studente on 10/07/25.
//
import Foundation
import CoreData

class WorkoutDayManager {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Create
    @discardableResult
    func createWorkoutDay(isCompleted: Bool,
                          muscles: [String],
                          workout: Workout) -> WorkoutDay {
        
        let workoutDay = WorkoutDay(context: context,
                                    isCompleted: isCompleted,
                                    workout: workout)
        
        saveContext()
        return workoutDay
    }
    
    // MARK: - Read
    func fetchAllWorkoutDays() -> [WorkoutDay] {
        let fetchRequest: NSFetchRequest<WorkoutDay> = WorkoutDay.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Errore nel recupero dei giorni di allenamento: \(error)")
            return []
        }
    }
    
    func fetchWorkoutDay(byID id: UUID) -> WorkoutDay? {
        let request: NSFetchRequest<WorkoutDay> = WorkoutDay.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try context.fetch(request).first
        } catch {
            print("Errore nella ricerca per ID: \(error)")
            return nil
        }
    }
    
    // MARK: - Update
    func updateWorkoutDay(_ workoutDay: WorkoutDay,
                          isCompleted: Bool? = nil,
                          muscles: [String]? = nil,
                          workout: Workout? = nil) {
        
        if let isCompleted = isCompleted {
            workoutDay.isCompleted = isCompleted
        }
        
        if let muscles = muscles {
            workoutDay.musclesList = muscles
        }
        
        if let workout = workout {
            workoutDay.workout = workout
        }
        
        saveContext()
    }
    
    // MARK: - Delete
    func deleteWorkoutDay(_ workoutDay: WorkoutDay) {
        context.delete(workoutDay)
        saveContext()
    }
    
    // MARK: - Save Context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Errore durante il salvataggio: \(error)")
            }
        }
    }
}
