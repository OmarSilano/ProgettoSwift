//
//  ExerciseManager.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

class WorkoutManager {
    
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Create
    @discardableResult
    func createWorkout(name: String,
                       difficulty: Difficulty? = nil,
                       weeks: Int16,
                       pathToImage: String? = nil) -> Workout {
        
        let workout = Workout(context: context,
                              name: name,
                              weeks: weeks,
                              imagePath: pathToImage,
                              difficulty: difficulty ?? .beginner)
        
        saveContext()
        return workout
    }

    // MARK: - Read
    func fetchAllWorkouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero dei workout: \(error)")
            return []
        }
    }

    func fetchWorkout(byID id: UUID) -> Workout? {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Errore nella ricerca per ID: \(error)")
            return nil
        }
    }

    // MARK: - Update
    func updateWorkout(_ workout: Workout,
                       name: String? = nil,
                       difficulty: Difficulty? = nil,
                       weeks: Int16? = nil,
                       pathToImage: String? = nil) {
        
        if let name = name { workout.name = name }
        if let difficulty = difficulty { workout.difficulty = difficulty.rawValue }
        if let weeks = weeks { workout.weeks = weeks }
        if let pathToImage = pathToImage { workout.pathToImage = pathToImage }
        
        saveContext()
    }

    // MARK: - Delete
    func deleteWorkout(_ workout: Workout) {
        context.delete(workout)
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
