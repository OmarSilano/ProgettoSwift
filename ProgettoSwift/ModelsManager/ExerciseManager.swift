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
    
    // MARK: - Private Seed Struct
        private struct ExerciseSeed: Codable {
            let name: String
            let muscle: String
            let method: String
            let difficulty: String
            let instructions: String
            let imageName: String?
            let videoName: String?
        }
        
    
        func preloadDefaultExercises() {
            let existing = fetchAllExercises()
            if !existing.isEmpty {
                print("⚠️ Esercizi già presenti, skip.")
                return
            }
            
            if let bundlePath = Bundle.main.resourcePath {
                print("📁 Contenuto del bundle:")
                let fileManager = FileManager.default
                if let contents = try? fileManager.contentsOfDirectory(atPath: bundlePath) {
                    contents.forEach { print($0) }
                }
            }

            guard let url = Bundle.main.url(forResource: "exercise", withExtension: "json") else {
                print("❌ JSON esercizi non trovato")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let seeds = try decoder.decode([ExerciseSeed].self, from: data)

                for seed in seeds {
                    guard
                        let muscle = MuscleGroup(rawValue: seed.muscle),
                        let method = Method(rawValue: seed.method),
                        let difficulty = Difficulty(rawValue: seed.difficulty)
                    else {
                        print("⚠️ Dato non valido in \(seed.name)")
                        continue
                    }

                    _ = createExercise(
                        name: seed.name,
                        difficulty: difficulty,
                        muscle: muscle,
                        method: method,
                        pathToImage: seed.imageName,
                        pathToVideo: seed.videoName,
                        instructions: seed.instructions
                    )
                }

                print("✅ Esercizi predefiniti caricati da JSON.")
            } catch {
                print("❌ Errore caricamento JSON: \(error)")
            }
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
    
    func fetchExercisesGroupedByMuscle() -> [MuscleGroup: [Exercise]] {
        let allExercises = fetchAllExercises()
        var grouped: [MuscleGroup: [Exercise]] = [:]

        for exercise in allExercises {
            guard let muscleRaw = exercise.muscle,
                  let muscle = MuscleGroup(rawValue: muscleRaw) else { continue }

            grouped[muscle, default: []].append(exercise)
        }

        return grouped
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
    
    func toggleBan(for exercise: Exercise) {
        exercise.isBanned.toggle()
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
