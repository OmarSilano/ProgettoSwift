import SwiftUI

@main
struct ProgettoSwiftApp: App {
    let persistenceController = PersistenceController.shared
    
    // Per testare il calendario nell'ipotesi in cui
    // l'app sia stata scaricata da un paio di mesi
    // (calendario navigabile)
    /*
    init() {
            #if DEBUG
            let twoMonthsAgo = Calendar.current.date(
                byAdding: .month,
                value: -2,
                to: Date()
            )!
            UserDefaults.standard.set(twoMonthsAgo, forKey: "appInstallDate")
            #endif
        }
     */

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

