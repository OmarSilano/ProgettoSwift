//
//  PersistanceController.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Errore nel caricamento di Core Data: \(error), \(error.userInfo)")
            }
        }
    }
}
