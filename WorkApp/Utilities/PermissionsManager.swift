import UserNotifications
import SwiftUI
import Photos

class Permissions {
    
    // Chiedo il permesso all'utente di inviargli notifiche
    @discardableResult
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        if settings.authorizationStatus == .notDetermined {
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                print("Error: request notification permission")
                return false
            }
        }
        
        return settings.authorizationStatus == .authorized
    }
    
    
    // Chiedo il permesso all'utente di poter accedere alla galleria
        func requestGalleryPermission() async -> Bool {
            let currentStatus = PHPhotoLibrary.authorizationStatus()

            switch currentStatus {
            case .authorized, .limited:
                // Già autorizzato o accesso limitato
                return true

            case .notDetermined:
                let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                return newStatus == .authorized || newStatus == .limited

            case .denied, .restricted:
                // Negato o ristretto, non possiamo procedere
                return false

            @unknown default:
                return false
            }
        }
    }
    
    

    

