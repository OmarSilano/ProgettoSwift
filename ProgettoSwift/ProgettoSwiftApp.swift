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

    /*
     // Utilizza onAppear, va bene utilizzarlo quando verranno definiti tutti gli elementi di default
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
     */
    
    // Carica ogni volta gli elementi di default da capo, utile in fase di sviluppo
    var body: some Scene {
        let context = persistenceController.container.viewContext

        // Preload prima della UI
        TypologyManager(context: context).preloadDefaultTypologies()
        ExerciseManager(context: context).preloadDefaultExercises()
        WorkoutManager(context: context).preloadDefaultWorkouts()

        return WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
        }
    }
}

