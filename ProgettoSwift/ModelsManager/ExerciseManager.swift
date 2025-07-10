//
//  ExerciseManager.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

class ExerciseManager {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Create
    @discardableResult
    func createExercise(name: String,
                        difficulty: Difficulty,
                        muscle: MuscleGroup,
                        method: String? = nil,
                        pathToImage: String? = nil,
                        pathToVideo: String? = nil,
                        isBanned: Bool = false,
                        instructions: String? = nil) -> Exercise {
        
        let exercise = Exercise(context: context,
                                name: name,
                                difficulty: difficulty,
                                muscle: muscle,
                                method: method,
                                pathToImage: pathToImage,
                                pathToVideo: pathToVideo,
                                isBanned: isBanned,
                                instructions: instructions)
        
        saveContext()
        return exercise
    }

    // MARK: - Read
    func fetchAllExercises() -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero degli esercizi: \(error)")
            return []
        }
    }

    func fetchExercise(byID id: UUID) -> Exercise? {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
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
    func updateExercise(_ exercise: Exercise,
                        name: String? = nil,
                        difficulty: Difficulty? = nil,
                        muscle: MuscleGroup? = nil,
                        method: String? = nil,
                        pathToImage: String? = nil,
                        pathToVideo: String? = nil,
                        isBanned: Bool? = nil,
                        instructions: String? = nil) {
        
        if let name = name { exercise.name = name }
        if let difficulty = difficulty { exercise.difficulty = difficulty.rawValue }
        if let muscle = muscle { exercise.muscle = muscle.rawValue }
        if let method = method { exercise.method = method }
        if let pathToImage = pathToImage { exercise.pathToImage = pathToImage }
        if let pathToVideo = pathToVideo { exercise.pathToVideo = pathToVideo }
        if let isBanned = isBanned { exercise.isBanned = isBanned }
        if let instructions = instructions { exercise.instructions = instructions }
        
        saveContext()
    }

    // MARK: - Delete
    func deleteExercise(_ exercise: Exercise) {
        context.delete(exercise)
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
