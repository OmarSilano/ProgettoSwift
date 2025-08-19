import UserNotifications
import SwiftUI
import CoreData

class Notifications {
    
    //è solo una prova va eliminata
    func dispatchNotification() async {
        
        let identifier = "prova"
        let title = "notifica di prova"
        let body = "Funziona?????"
        let hour = 12
        let minute = 17
        let repeats = true
        
        var dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        await scheduleNotification(title: title, body: body, identifier: identifier, dateComponents: dateComponents, repeats: repeats)
        
    }
    
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
    
    /*
    //Funzione che ti manda una notifica ogni 3 giorni se non completi un WorkoutDay da almeno 3 giorni (per ora in modo locale)
    func dispatchComeBackTrainingNotification() {
        
        let manager = WorkoutDayCompletedManager(context: context)

        let completions = manager.fetchCompletionsLastNDays(n: 3)   //lista di giorni completati negli ultimi 3 giorni
                
                guard completions.isEmpty else {
                    print("Allenamenti recenti trovati, nessuna notifica inviata.")
                    return
                }

        
        let identifier = "comeBack"
        let title = "Come back training!"
        let body = "It's been 3 days since you last completed an exercise. Don't give up!"
        let hour = 10
        let minute = 0
        let repeats = true
        
        
        var dateComponents = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        scheduleNotification(title: title, body: body, identifier: identifier, dateComponents: dateComponents, repeats: repeats)
        
    }
     */
    
    //metodo per cancellare le notifiche
    func cancelNotification(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notifica \(identifier) cancellata.")
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
    
    //true se ho i permessi di notifiche, false altrimenti
    private func areNotificationsEnabled() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    
    
    

