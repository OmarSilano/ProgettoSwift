import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")

        if inMemory {
            // Solo per test (non persistente)
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let description = container.persistentStoreDescriptions.first
            description?.shouldMigrateStoreAutomatically = true
            description?.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("❌ Errore nel caricamento di Core Data: \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data store caricato in: \(storeDescription.url?.absoluteString ?? "N/A")")
            }
        }

        // Migliora la gestione delle modifiche su più thread
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
