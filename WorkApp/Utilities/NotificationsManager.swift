import UserNotifications
import SwiftUI
import CoreData

class Notifications {
    
    //Notifica che ogni lunedì alle 7 di mattina ti ricorda di allenarti
    func dispatchNotificationEveryMonday() async {
        
        let identifier = "monday"
        let title = "A new week has started!"
        let body = "Keep Working!"
        let hour = 7
        let minute = 0
        let repeats = true
        
        
        var dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current)
        dateComponents.weekday = 2  //domenica = 1, lunedì = 2 ecc.
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        await scheduleNotification(title: title, body: body, identifier: identifier, dateComponents: dateComponents, repeats: repeats)
    }
    
    //Notifica schedulata al momento della creazione di un nuovo workout.
    //Se crei un workout con durata in settimane diversa da 0, allora viene schedulata una notifica di fine workout
    func dispatchNotificationWorkoutEnd(workout: Workout) async {
        
        // Verifico che id e name esistano, altrimenti esco
        guard let workoutID = workout.id, let workoutName = workout.name else {
            print("Workout non valido, impossibile schedulare la notifica")
            return
        }
        
        let identifier = "workoutEnd_\(workoutID)"
        let title = "Workout finished!"
        let body = "Congratulations! You have completed \(workoutName)! Are you looking for a new challenge?"
        let repeats = false
        
        // Se weeks è lasciato a 0, non schedulo niente
        guard workout.weeks > 0 else {
            return
        }
        
        //Verifico che venga schedulata una notifica ad una data che non restituisca nil se va fuori il range disponibile
        guard let endDate = Calendar.current.date(byAdding: .weekOfYear,
                                                  value: Int(workout.weeks),
                                                  to: Date()) else {
            print("Errore nel calcolo della data di fine workout")
            return
        }
        
        //la notifica arriverà allo stesso giorno e stesso orario in cui è stato creato il workout, dopo il numero di settimane inserito dall'utente alla creazione
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: endDate
        )
        
        await scheduleNotification(title: title, body: body, identifier: identifier, dateComponents: dateComponents, repeats: repeats)
    }
    
    func dispatchNotificationEditedWorkoutEnd(workout: Workout) async {
        
        guard let workoutID = workout.id else {
            print("Workout non valido, impossibile aggiornare la notifica")
            return
        }
        
        cancelNotification(with: "workoutEnd_\(workoutID)")
        
        await dispatchNotificationWorkoutEnd(workout: workout)
        
    }
    
    // Funzione generica per pianificare una notifica, chiamato dai dispatch
    private func scheduleNotification(title: String, body: String, identifier: String, dateComponents: DateComponents, repeats: Bool) async {
        
        let granted :Bool = await areNotificationsEnabled()
        
        //Verifico di avere i permessi
            guard granted else {
                print("Permesso negato, non invio notifica")
                return
            }
            
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = title
            notificationContent.body = body
            notificationContent.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
            
            let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
            
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Notifica \(identifier) programmata con successo.")
        } catch {
            print("Errore nella programmazione della notifica \(identifier): \(error.localizedDescription)")
        }

        }
    }

    //metodo per cancellare le notifiche
    private func cancelNotification(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notifica \(identifier) cancellata.")
    }
    
    //true se ho i permessi di notifiche, false altrimenti
    private func areNotificationsEnabled() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    
    
    

