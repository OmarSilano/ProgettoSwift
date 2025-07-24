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
    
    func createTempWorkout(
        name: String,
        difficulty: Difficulty? = nil,
        weeks: Int16,
        pathToImage: String? = nil,
        category: Category? = nil,
        isSaved: Bool? = nil
    ) -> Workout {
        let workout = Workout(
            context: context,
            name: name,
            weeks: weeks,
            imagePath: pathToImage,
            difficulty: difficulty ?? .beginner,
            category: category,
            isSaved: isSaved ?? false
        )
        return workout
    }
    
    // MARK: - Private Seed Structures
    private struct WorkoutSeed: Codable {
        let category: String
        let difficulty: String
        let name: String
        let weeks: Int16
        let pathToImage: String
        let days: [WorkoutDaySeed]
    }
    private struct WorkoutDaySeed: Codable {
        let name: String
        let details: [WorkoutDayDetailSeed]
    }
    private struct WorkoutDayDetailSeed: Codable {
        let exerciseName: String
        let typologyName: String
    }
    
    // MARK: - Caricamento default workout
    private func createWorkoutFromSeed(_ seed: WorkoutSeed) {
        let workoutDayManager = WorkoutDayManager(context: context)
        let detailManager = WorkoutDayDetailManager(context: context)
        let typologyManager = TypologyManager(context: context)
        let exerciseManager = ExerciseManager(context: context)

        // Crea il Workout base
        let workout = Workout(
            context: context,
            name: seed.name,
            weeks: seed.weeks,
            imagePath: seed.pathToImage,
            difficulty: Difficulty(rawValue: seed.difficulty),
            category: Category(rawValue: seed.category),
            isSaved: false // sempre false per i default
        )

        // Recupera tutti gli esercizi disponibili
        let allExercises = exerciseManager.fetchAllExercises()

        for daySeed in seed.days {
            // Crea WorkoutDay
            let workoutDay = workoutDayManager.createTempWorkoutDay(
                isCompleted: false,
                name: daySeed.name,
                muscles: [],
                workout: workout,
            )

            // Crea i dettagli del giorno
            for detailSeed in daySeed.details {
                // Trova l'esercizio per nome
                guard let exercise = allExercises.first(where: { $0.name == detailSeed.exerciseName }) else {
                    print("⚠️ Esercizio '\(detailSeed.exerciseName)' non trovato, skip.")
                    continue
                }

                // Trova la tipologia
                guard let typology = typologyManager.fetchAllTypologies().first(where: { $0.name == detailSeed.typologyName }) else {
                    print("⚠️ Tipologia '\(detailSeed.typologyName)' non trovata, skip.")
                    continue
                }

                // Crea il dettaglio
                _ = detailManager.createTempWorkoutDayDetail(
                    workoutDay: workoutDay,
                    exercise: exercise,
                    typology: typology
                )
            }

            // ✅ Aggiorna automaticamente i muscoli del giorno
            workoutDay.updateMusclesFromDetails()
        }

        print("✅ Workout '\(seed.name)' creato correttamente!")
    }
    
    func preloadDefaultWorkouts() {
        // Controllo se i workout di default esistono già
        let existing = fetchAllWorkouts().filter { $0.category != nil }
        if !existing.isEmpty {
            print("⚠️ Workout di default già presenti, skip.")
            return
        }

        // Recupero il JSON
        guard let url = Bundle.main.url(forResource: "workout", withExtension: "json") else {
            print("❌ JSON workout non trovato!")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let seeds = try decoder.decode([WorkoutSeed].self, from: data)

            print("📄 Preload di \(seeds.count) workout di default dal JSON...")

            for seed in seeds {
                print("➡️ Creazione workout '\(seed.name)'...")
                createWorkoutFromSeed(seed) // Crea TUTTO in memoria
            }

            // Unico salvataggio per tutto il preload
            saveContext()
            print("✅ Tutti i workout di default caricati con successo.")

        } catch {
            print("❌ Errore caricamento JSON workout: \(error)")
        }
    }




    // MARK: - Create
    @discardableResult
    func createWorkout(name: String,
                       difficulty: Difficulty? = nil,
                       weeks: Int16,
                       pathToImage: String? = nil,
                       category: Category? = nil,
                       isSaved: Bool? = nil) -> Workout {

        let workout = Workout(context: context,
                              name: name,
                              weeks: weeks,
                              imagePath: pathToImage,
                              difficulty: difficulty ?? .beginner,
                              category: category,
                              isSaved: isSaved ?? false
                            )

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
    
    //  recupero workout salvati
    func fetchSavedWorkouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "isSaved = true")
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero dei workout salvati: \(error)")
            return []
        }
    }
    
    //recupero workout in base alla categoria
    func fetchWorkoutByCategory(_ category: Category) -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category.rawValue)
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero dei workout per categoria: \(error)")
            return []
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
    
    // MARK: - Update isSaved
    func toggleSavedStatus(for workout: Workout) {
        workout.isSaved.toggle() // Inverte il valore true/false
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
    
    func cloneWorkout(_ original: Workout) {
        let clonedWorkout = Workout(
            context: context,
            name: original.name ?? "Unnamed",
            weeks: original.weeks,
            imagePath: original.pathToImage,
            difficulty: nil,
            category: nil,
            isSaved: true
        )

        var totalDays: Int = 0

        if let originalDays = original.workoutDay?.allObjects as? [WorkoutDay] {
            for originalDay in originalDays {
                let clonedDay = WorkoutDay(context: context)
                clonedDay.id = UUID()
                clonedDay.name = originalDay.name
                clonedDay.isCompleted = false
                clonedDay.workout = clonedWorkout

                totalDays += 1

                if let originalDetails = originalDay.workoutDayDetail?.allObjects as? [WorkoutDayDetail] {
                    for originalDetail in originalDetails {
                        let clonedDetail = WorkoutDayDetail(context: context)
                        clonedDetail.id = UUID()
                        clonedDetail.exercise = originalDetail.exercise
                        clonedDetail.typology = originalDetail.typology
                        clonedDetail.workoutDay = clonedDay
                    }
                }
                
                // Calcola muscoli del giorno
                clonedDay.updateMusclesFromDetails()
            }
        }

        // Imposta i giorni totali
        clonedWorkout.days = Int16(totalDays)

        saveContext()
        print("✅ Workout '\(clonedWorkout.name ?? "Workout")' clonato con successo.")
    }

    /*
    func preloadDefaultWorkouts() {
        let workoutDayManager = WorkoutDayManager(context: context)
        let exerciseManager = ExerciseManager(context: context)
        let detailManager = WorkoutDayDetailManager(context: context)
        let typologyManager = TypologyManager(context: context)

        // ✅ Controlla se il workout default esiste già
        let existing = fetchWorkoutByCategory(.hypertrophy).filter {
            $0.name == "Hypertrophy A" && $0.isSaved == false
        }
        if !existing.isEmpty {
            print("✅ Workout default già presente, skip preload")
            return
        }

        // ✅ Recupera o crea la tipologia base
        let typology = typologyManager.fetchAllTypologies().first { $0.name == "4x10" }
            ?? typologyManager.createTypology(
                name: "4x10",
                detail: "4 sets of 10 reps",
                isDefault: true
            )

        // ✅ Recupera esercizi beginner
        let allExercises = exerciseManager.fetchAllExercises()
        let beginnerExercises = allExercises.filter {
            guard let raw = $0.difficulty, let diff = Difficulty(rawValue: raw) else { return false }
            return diff == .beginner
        }

        func pick(_ muscle: MuscleGroup, method: Method? = nil) -> Exercise? {
            return beginnerExercises.first {
                $0.muscle == muscle.rawValue && (method == nil || $0.method == method!.rawValue)
            }
        }

        // --- GIORNO 1: Petto + Tricipiti
        guard
            let benchPress = pick(.chest, method: .pushChest),
            let tricepsDip = pick(.arms, method: .tricepsArms)
        else {
            print("⚠️ Giorno 1: esercizi non sufficienti, preload annullato")
            return
        }

        // --- GIORNO 2: Schiena + Bicipiti
        guard
            let barbellRow = pick(.back, method: .rowBack),
            let bicepCurl = pick(.arms, method: .bicepsArms)
        else {
            print("⚠️ Giorno 2: esercizi non sufficienti, preload annullato")
            return
        }

        // --- GIORNO 3: Gambe + Spalle
        guard
            let squat = pick(.legs, method: .vPushLegs),
            let lateralRaise = pick(.shoulders, method: .lateralRaiseShoulders)
        else {
            print("⚠️ Giorno 3: esercizi non sufficienti, preload annullato")
            return
        }

        // ✅ CREA IL WORKOUT (temp, non salvato subito)
        let workout = createTempWorkout(
            name: "Hypertrophy A",
            difficulty: .beginner,
            weeks: 4,
            pathToImage: "Hypertrophy",
            category: .hypertrophy
        )

        // --- GIORNO 1
        let day1 = workoutDayManager.createTempWorkoutDay(
            isCompleted: false,
            name: "Day 1 - Chest & Triceps",
            muscles: [.chest, .arms],
            workout: workout
        )
        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day1,
            exercise: benchPress,
            typology: typology
        )
        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day1,
            exercise: tricepsDip,
            typology: typology
        )

        // --- GIORNO 2
        let day2 = workoutDayManager.createTempWorkoutDay(
            isCompleted: false,
            name: "Day 2 - Back & Biceps",
            muscles: [.back, .arms],
            workout: workout
        )
        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day2,
            exercise: barbellRow,
            typology: typology
        )
        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day2,
            exercise: bicepCurl,
            typology: typology
        )

        // --- GIORNO 3
        let day3 = workoutDayManager.createTempWorkoutDay(
            isCompleted: false,
            name: "Day 3 - Legs & Shoulders",
            muscles: [.legs, .shoulders],
            workout: workout
        )
        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day3,
            exercise: squat,
            typology: typology
        )
        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day3,
            exercise: lateralRaise,
            typology: typology
        )
        if let crunch = beginnerExercises.first(where: { $0.name == "Crunch" }) {
            _ = detailManager.createTempWorkoutDayDetail(
                workoutDay: day3,
                exercise: crunch,
                typology: typology
            )
        } else {
            print("⚠️ Crunch non trovato nei beginnerExercises")
        }

        // ✅ SALVATAGGIO UNICO di tutto il grafo
        do {
            try context.save()
            print("✅ Workout di default 'Hypertrophy A' con 3 giorni e dettagli salvato con successo.")
        } catch {
            print("❌ Errore salvataggio workout default: \(error)")
        }
    }

*/


}
