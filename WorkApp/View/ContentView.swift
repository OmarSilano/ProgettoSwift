//
//  ContentView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//
import SwiftUI



struct ContentView: View {
    
    var body: some View {
        
        TabBarView()
            .task {
                //chiedo il permesso per le notifiche
                let granted: Bool = await Permissions().requestNotificationPermission()
                
                //ritorno un valore bool per capire se pianificare o meno la notifica
                if granted {
                    let notifications = Notifications()
                    await notifications.dispatchNotificationEveryMonday()
                }
            }
        
    }
}

