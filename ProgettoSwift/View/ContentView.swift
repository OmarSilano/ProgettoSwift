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
                await Permissions().requestNotificationPermission()
            }
        
    }
}

