import Foundation
import CoreData

class WorkoutDayDetailManager {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createTempWorkoutDayDetail(workoutDay: WorkoutDay,
                                    exercise: Exercise,
                                    typology: Typology,
                                    orderIndex: Int16? = nil) -> WorkoutDayDetail {
        
        let finalOrderIndex: Int16
        if let index = orderIndex {
            finalOrderIndex = index
        } else {
            finalOrderIndex = Int16(workoutDay.workoutDayDetail?.count ?? 0)
        }
        
        let detail = WorkoutDayDetail(context: context,
                                      workoutDay: workoutDay,
                                      exercise: exercise,
                                      typology: typology,
                                      orderIndex: finalOrderIndex)
        
        workoutDay.updateMusclesFromDetails()
        return detail
    }
    
    
    // MARK: - Create
    @discardableResult
    func createWorkoutDayDetail(workoutDay: WorkoutDay,
                                exercise: Exercise,
                                typology: Typology,
                                orderIndex: Int16? = nil) -> WorkoutDayDetail {
        
        // Calcolo l'ordine prima di creare l'oggetto
        let finalOrderIndex: Int16
        if let index = orderIndex {
            finalOrderIndex = index
        } else {
            finalOrderIndex = Int16(workoutDay.workoutDayDetail?.count ?? 0)
        }
        
        let detail = WorkoutDayDetail(context: context,
                                      workoutDay: workoutDay,
                                      exercise: exercise,
                                      typology: typology,
                                      orderIndex: finalOrderIndex)
        
        workoutDay.updateMusclesFromDetails()
        saveContext()
        return detail
    }
    
    
    // MARK: - Read
    func fetchAllWorkoutDayDetails() -> [WorkoutDayDetail] {
        let request: NSFetchRequest<WorkoutDayDetail> = WorkoutDayDetail.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel fetch degli esercizi all'interno del giorno: \(error)")
            return []
        }
    }
    
    func fetchWorkoutDayDetail(byID id: UUID) -> WorkoutDayDetail? {
        let request: NSFetchRequest<WorkoutDayDetail> = WorkoutDayDetail.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try context.fetch(request).first
        } catch {
            print("Errore nel fetch per ID: \(error)")
            return nil
        }
    }
    
    // MARK: - Update
    func updateWorkoutDayDetail(_ detail: WorkoutDayDetail,
                                exercise: Exercise? = nil,
                                typology: Typology? = nil) {
        
        if let exercise = exercise {
            detail.exercise = exercise
            detail.workoutDay?.updateMusclesFromDetails()
        }
        if let typology = typology {
            detail.typology = typology
        }
        
        saveContext()
    }
    
    // MARK: - Delete
    func deleteWorkoutDayDetail(_ detail: WorkoutDayDetail) {
        context.delete(detail)
        
        detail.workoutDay?.updateMusclesFromDetails()
        
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
