//
//  WorkoutDay.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import Foundation
import CoreData

extension WorkoutDay {
    
    // details ordinati in base all'orderIndex
    var sortedDetails: [WorkoutDayDetail] {
        let detailsArray = (workoutDayDetail as? Set<WorkoutDayDetail>) ?? []
        return detailsArray.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    // muscles come array di stringhe, con default empty array se nil
    var musclesList: [MuscleGroup] {
        get {
            (muscles as? [String])?.compactMap { MuscleGroup(rawValue: $0) } ?? []
        }
        set {
            muscles = newValue.map { $0.rawValue } as NSObject
        }
    }
    
    // ricalcola i gruppi muscolari allenati
    func updateMusclesFromDetails() {
        // Prendi i dettagli associati al giorno di allenamento
        guard let details = workoutDayDetail as? Set<WorkoutDayDetail> else {
            musclesList = []
            return
        }
        
        // Raccogli i muscoli degli esercizi, se validi
        let muscles = details.compactMap { $0.exercise?.muscle }
        
        // Converti le stringhe in enum MuscleGroup
        let groups = muscles.compactMap { MuscleGroup(rawValue: $0) }
        
        // Rimuovi duplicati e ordina
        let uniqueSorted = Array(Set(groups)).sorted { $0.rawValue < $1.rawValue }
        
        // Salva nella variabile musclesList
        musclesList = uniqueSorted
    }
    
    
    convenience init(context: NSManagedObjectContext,
                     id: UUID = UUID(),
                     name: String,
                     isCompleted: Bool = false,
                     muscles: [MuscleGroup] = [],
                     workout: Workout) {
        self.init(context: context)
        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.workout = workout
        self.musclesList = [] // inizialmente vuoto
    }
    
    func toPlainText() -> String {
        var txt = "📅 Day: \(name ?? "Workout Day")\n"
        
        let muscles = musclesList.map { $0.rawValue }
        if !muscles.isEmpty {
            txt += "Muscles: \(muscles.joined(separator: ", "))\n"
        }
        
        let details = (workoutDayDetail?.allObjects as? [WorkoutDayDetail]) ?? []
        for detail in details {
            let exName = detail.exercise?.name ?? "Unknown"
            let typology = detail.typology?.name ?? "-"
            txt += "- \(exName) • \(typology)\n"
        }
        
        txt += "\n"
        return txt
    }
}
