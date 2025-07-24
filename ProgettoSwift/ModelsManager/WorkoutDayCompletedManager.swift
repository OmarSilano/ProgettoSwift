//
//  WorkoutDayCompletedManager.swift
//  ProgettoSwift
//
//  Created by Studente on 15/07/25.
//
import Foundation
import CoreData

class WorkoutDayCompletedManager {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Create
    @discardableResult
    func markAsCompleted(workoutDay: WorkoutDay, date: Date) -> WorkoutDayCompleted {
        let completed = WorkoutDayCompleted(context: context,
                                            workoutDay: workoutDay,
                                            date: date)
        saveContext()
        return completed
    }

    // MARK: - Read
    func fetchAllCompletions() -> [WorkoutDayCompleted] {
        let request: NSFetchRequest<WorkoutDayCompleted> = WorkoutDayCompleted.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero dei completamenti: \(error)")
            return []
        }
    }

    func fetchCompletion(for workoutDay: WorkoutDay, on date: Date) -> WorkoutDayCompleted? {
        let request: NSFetchRequest<WorkoutDayCompleted> = WorkoutDayCompleted.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "workoutDay == %@", workoutDay),
            NSPredicate(format: "date == %@", date as NSDate)
        ])
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            print("Errore nel recupero del completamento: \(error)")
            return nil
        }
    }

    func fetchCompletionDates(for workoutDay: WorkoutDay) -> [Date] {
        let request: NSFetchRequest<WorkoutDayCompleted> = WorkoutDayCompleted.fetchRequest()
        request.predicate = NSPredicate(format: "workoutDay == %@", workoutDay)
        do {
            return try context.fetch(request).compactMap { $0.date }
        } catch {
            print("Errore nel recupero delle date completate: \(error)")
            return []
        }
    }
    
    
    func fetchCompletionsLastNDays(n: Int) -> [WorkoutDayCompleted] {
            let request: NSFetchRequest<WorkoutDayCompleted> = WorkoutDayCompleted.fetchRequest()

            let calendar = Calendar.current
            let now = Date()
            guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -n, to: now) else {
                return []
            }

            // Filtriamo per date negli ultimi 7 giorni
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", sevenDaysAgo as NSDate, now as NSDate)

            do {
                return try context.fetch(request)
            } catch {
                print("Errore nel recupero completamenti ultimi \(n) giorni: \(error)")
                return []
            }
        }
    
    func fetchCountLastNDaysByMuscle(n: Int) -> [MuscleGroup: Int] {
        let completions = fetchCompletionsLastNDays(n: n)
            var counts: [MuscleGroup: Int] = [:]
            
            for completion in completions {
                // Dal WorkoutDayCompleted prendo il relativo workoutDay
                guard let workoutDay = completion.workoutDay else { continue }
                
                // Dal WorkoutDay prendo i dettagli (to-many)
                guard let details = workoutDay.workoutDayDetail as? Set<WorkoutDayDetail> else { continue }
                
                for detail in details {
                    guard let exercise = detail.exercise else { continue }
                    
                    // Leggiamo il muscle dell'esercizio
                    if let raw = exercise.muscle,
                       let group = MuscleGroup(rawValue: raw) {
                        counts[group, default: 0] += 1
                    }
                }
            }
            
            return counts
        }

    // MARK: - Delete
    func deleteCompletion(for workoutDay: WorkoutDay, on date: Date) {
        if let toDelete = fetchCompletion(for: workoutDay, on: date) {
            context.delete(toDelete)
            saveContext()
        }
    }

    func deleteAllCompletions(for workoutDay: WorkoutDay) {
        let request: NSFetchRequest<WorkoutDayCompleted> = WorkoutDayCompleted.fetchRequest()
        request.predicate = NSPredicate(format: "workoutDay == %@", workoutDay)
        do {
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Errore durante la cancellazione dei completamenti: \(error)")
        }
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
