//
//  ExerciseManager.swift
//  ProgettoSwift
//
//  Created by Studente on 07/07/25.
//
//
//  ExerciseManager.swift
//  ProgettoSwift
//
//  Created by [Tuo Nome] on [Data].
//
import Foundation
import CoreData

class TypologyManager {
    
    private let context: NSManagedObjectContext
    static let defaultDetail :String = "No Details..."

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Create
    @discardableResult
    func createTypology(name: String,
                        detail: String? = TypologyManager.defaultDetail,
                        isDefault: Bool = false) -> Typology {
        
        let typology = Typology(context: context,
                              name: name,
                              detail: detail,
                              isDefault: isDefault)
        
        saveContext()
        return typology
    }

    // MARK: - Read
    func fetchAllTypologies() -> [Typology] {
        let request: NSFetchRequest<Typology> = Typology.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero delle tipologie: \(error)")
            return []
        }
    }

    func fetchTypology(byID id: UUID) -> Typology? {
        let request: NSFetchRequest<Typology> = Typology.fetchRequest()
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
    func updateTypology(_ typology: Typology,
                        name: String? = nil,
                        detail: String? = nil,
                        isDefault: Bool? = nil
                       ) {
        
        if let name = name { typology.name = name }
        if let detail = detail { typology.detail = detail }
        if let isDefault = isDefault { typology.isDefault = isDefault }
        
        saveContext()
    }

    // MARK: - Delete
    func deleteTypology(_ typology: Typology) {
        context.delete(typology)
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
    
    func fetchDefaultTypologies() -> [Typology] {
        let request: NSFetchRequest<Typology> = Typology.fetchRequest()
        request.predicate = NSPredicate(format: "isDefault == true")
        
        do {
            return try context.fetch(request)
        } catch {
            print("Errore nel recupero delle tipologie default: \(error)")
            return []
        }
    }

    
}
