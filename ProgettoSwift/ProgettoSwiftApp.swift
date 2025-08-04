import SwiftUI
import CoreData

@main
struct ProgettoSwiftApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .dark // UIKit
    }
    
    // Utilizza onAppear, va bene utilizzarlo quando verranno definiti tutti gli elementi di default
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    let context = persistenceController.container.viewContext
                    
                    /* DEBUG: RESET DATABASE */
                    // resetDatabase()
                    
                    TypologyManager(context: context).preloadDefaultTypologies()
                    ExerciseManager(context: context).preloadDefaultExercises()
                    WorkoutManager(context: context).preloadDefaultWorkouts()
                }
        }
    }
    /* DEBUG */
    private func resetDatabase() {
        let coordinator = persistenceController.container.persistentStoreCoordinator
        
        for store in coordinator.persistentStores {
            if let url = store.url {
                do {
                    // 1. Rimuove lo store dal coordinator
                    try coordinator.destroyPersistentStore(
                        at: url,
                        ofType: store.type,
                        options: nil
                    )
                    print("🗑 Database store removed at \(url)")
                } catch {
                    print("❌ Error destroying persistent store: \(error)")
                }
            }
        }
        
        // 2. Ricrea lo store
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistenceController.container.persistentStoreDescriptions.first?.url,
                options: nil
            )
            print("✅ New persistent store created successfully")
        } catch {
            print("❌ Error creating new persistent store: \(error)")
        }
    }
}

