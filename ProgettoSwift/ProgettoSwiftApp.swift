import SwiftUI

@main
struct ProgettoSwiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    let context = persistenceController.container.viewContext
                    TypologyManager(context: context).preloadDefaultTypologies()
                    ExerciseManager(context: context).preloadDefaultExercises()
                    WorkoutManager(context: context).preloadDefaultWorkouts()
                }
        }
    }
}

