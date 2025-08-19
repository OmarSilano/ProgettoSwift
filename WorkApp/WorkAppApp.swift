import SwiftUI
import CoreData

@main
struct WorkAppApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        UIView.appearance().overrideUserInterfaceStyle = .dark

        #if DEBUG
        // Esegui reset + preload UNA VOLTA all'avvio
        let coordinator = persistenceController.container.persistentStoreCoordinator
       resetDatabase(coordinator: coordinator)

        let context = persistenceController.container.viewContext
        TypologyManager(context: context).preloadDefaultTypologies()
        ExerciseManager(context: context).preloadDefaultExercises()
        WorkoutManager(context: context).preloadDefaultWorkouts()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - DEBUG reset
#if DEBUG
private func resetDatabase(coordinator: NSPersistentStoreCoordinator) {
    for store in coordinator.persistentStores {
        if let url = store.url {
            do {
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

    do {
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: coordinator.persistentStores.first?.url
                ?? PersistenceController.shared.container.persistentStoreDescriptions.first?.url,
            options: nil
        )
        print("✅ New persistent store created successfully")
    } catch {
        print("❌ Error creating new persistent store: \(error)")
    }
}
#endif
