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
                        method: Method,
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
                        method: Method? = nil,
                        pathToImage: String? = nil,
                        pathToVideo: String? = nil,
                        isBanned: Bool? = nil,
                        instructions: String? = nil) {
        
        if let name = name { exercise.name = name }
        if let difficulty = difficulty { exercise.difficulty = difficulty.rawValue }
        if let muscle = muscle { exercise.muscle = muscle.rawValue }
        if let method = method { exercise.method = method.rawValue }
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
    
    func preloadDefaultExercises() {
        let existing = fetchAllExercises()
        if !existing.isEmpty {
            print("⚠️ Esercizi già presenti, skip.")
            return
        }

        let exercises: [(String, MuscleGroup, Method, Difficulty, String, String?)] = [
            ("Bench Press", .chest, .pushChest, .beginner, "Lie on a bench and push the barbell upward.", "bench_press"),
            ("Incline Dumbbell Press", .chest, .pushChest, .intermediate, "Press dumbbells upward at an incline.", nil),
            ("Pull-Up", .back, .pullUpBack, .intermediate, "Hang and pull yourself up.", "pull_up"),
            ("Barbell Row", .back, .rowBack, .beginner, "Pull barbell to your abdomen while bent over.", nil),
            ("Bicep Curl", .arms, .bicepsArms, .beginner, "Curl the dumbbell upwards.", "bicep_curl"),
            ("Triceps Dip", .arms, .tricepsArms, .beginner, "Lower and lift yourself on parallel bars.", nil),
            ("Crunch", .abs, .upperAbs, .beginner, "Lift shoulders off the floor contracting abs.", nil),
            ("Leg Raise", .abs, .lowerAbs, .intermediate, "Raise your legs while lying down.", "leg_raise"),
            ("Shoulder Press", .shoulders, .pushShoulders, .intermediate, "Push weights above your head.", "shoulder_press"),
            ("Lateral Raise", .shoulders, .lateralRaiseShoulders, .beginner, "Raise arms sideways.", nil),
            ("Squat", .legs, .vPushLegs, .beginner, "Lower and push your body back up.", "squat"),
            ("Leg Press", .legs, .hPushLegs, .intermediate, "Push the platform with your feet.", nil)
        ]

        for (name, muscle, method, difficulty, instructions, imageName) in exercises {
            _ = createExercise(
                name: name,
                difficulty: difficulty,
                muscle: muscle,
                method: method,
                pathToImage: imageName,
                instructions: instructions
            )
        }

        print("✅ Esercizi predefiniti caricati.")
    }



}
