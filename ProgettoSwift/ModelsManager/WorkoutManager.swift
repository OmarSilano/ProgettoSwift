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
                       pathToImage: String? = nil,
                       category: Category) -> Workout {

        let workout = Workout(context: context,
                              name: name,
                              weeks: weeks,
                              imagePath: pathToImage,
                              difficulty: difficulty ?? .beginner,
                              category: category) 

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
            difficulty: Difficulty(rawValue: original.difficulty ?? ""),
            category: Category(rawValue: original.category ?? ""),
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
                clonedDay.muscles = originalDay.muscles

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
            }
        }

        // Imposta i giorni totali
        clonedWorkout.days = Int16(totalDays)

        saveContext()
        print("✅ Workout '\(clonedWorkout.name ?? "Workout")' clonato con successo.")
    }

    
    func preloadDefaultWorkouts() {
        let workoutDayManager = WorkoutDayManager(context: context)
        let exerciseManager = ExerciseManager(context: context)
        let detailManager = WorkoutDayDetailManager(context: context)
        let typologyManager = TypologyManager(context: context)

        let existing = fetchWorkoutByCategory(.hypertrophy).filter {
            $0.name == "Hypertrophy A" && $0.isSaved == false
        }
        if !existing.isEmpty { return }

        let typology = typologyManager.fetchAllTypologies().first { $0.name == "4x10" }
            ?? typologyManager.createTypology(name: "4x10", detail: "4 sets of 10 reps", isDefault: true)

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
            print("⚠️ Giorno 1: esercizi non sufficienti.")
            return
        }

        // --- GIORNO 2: Schiena + Bicipiti
        guard
            let barbellRow = pick(.back, method: .rowBack),
            let bicepCurl = pick(.arms, method: .bicepsArms)
        else {
            print("⚠️ Giorno 2: esercizi non sufficienti.")
            return
        }

        // --- GIORNO 3: Gambe + Spalle
        guard
            let squat = pick(.legs, method: .vPushLegs),
            let lateralRaise = pick(.shoulders, method: .lateralRaiseShoulders)
        else {
            print("⚠️ Giorno 3: esercizi non sufficienti.")
            return
        }

        // Crea Workout
        let workout = createWorkout(
            name: "Hypertrophy A",
            difficulty: .beginner,
            weeks: 4,
            pathToImage: "Hypertrophy",
            category: .hypertrophy
        )

        // --- GIORNO 1
        let day1 = workoutDayManager.createWorkoutDay(
            isCompleted: false,
            name: "Day 1 - Chest & Triceps",
            muscles: [.chest, .arms],
            workout: workout
        )
        _ = detailManager.createWorkoutDayDetail(workoutDay: day1, exercise: benchPress, typology: typology)
        _ = detailManager.createWorkoutDayDetail(workoutDay: day1, exercise: tricepsDip, typology: typology)

        // --- GIORNO 2
        let day2 = workoutDayManager.createWorkoutDay(
            isCompleted: false,
            name: "Day 2 - Back & Biceps",
            muscles: [.back, .arms],
            workout: workout
        )
        _ = detailManager.createWorkoutDayDetail(workoutDay: day2, exercise: barbellRow, typology: typology)
        _ = detailManager.createWorkoutDayDetail(workoutDay: day2, exercise: bicepCurl, typology: typology)

        // --- GIORNO 3
        let day3 = workoutDayManager.createWorkoutDay(
            isCompleted: false,
            name: "Day 3 - Legs & Shoulders",
            muscles: [.legs, .shoulders],
            workout: workout
        )
        _ = detailManager.createWorkoutDayDetail(workoutDay: day3, exercise: squat, typology: typology)
        _ = detailManager.createWorkoutDayDetail(workoutDay: day3, exercise: lateralRaise, typology: typology)
        if let crunch = beginnerExercises.first(where: { $0.name == "Crunch" }) {
            _ = detailManager.createWorkoutDayDetail(workoutDay: day3, exercise: crunch, typology: typology)
        } else {
            print("⚠️ Crunch non trovato nei beginnerExercises.")
        }
        

        print("✅ Workout di default 'Hypertrophy A' con 3 giorni creato.")
    }



}
