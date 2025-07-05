//
//  NewTabView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Int = 0 //mi indica quale tabItem è selezionato (per poter mettere il fill dei symbols)
    let workouts: [Workout]
    
    init(workouts: [Workout]) {
        self.workouts = workouts

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.unselectedItemTintColor = UIColor(named:"TabBarSymbolColor")

        if let tabBarColor = UIColor(named: "TabBarColor") {
            tabBarAppearance.backgroundColor = tabBarColor.withAlphaComponent(0.9) //opacità = 90%
        } else {
            tabBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        }
    }

    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("EXPLORE")
                }
                .tag(0)
            
            WorkoutView(workouts: workouts)
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("WORKOUT")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("STATS")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("SETTINGS")
                }
                .tag(3)
        }
        .tint(Color("SecondaryColor"))
    }
}
    

#Preview {
    let workoutsPreview: [Workout] = [
        Workout(name: "PIRAMIDALE A", days: "X Days", weeks: "A Weeks"),
        Workout(name: "PIRAMIDALE INVERSO B", days: "Y Days", weeks: "B Weeks"),
        Workout(name: "10X4 C", days: "Z Days", weeks: "C Weeks"),
        Workout(name: "8X4 D", days: "W Days", weeks: "D Weeks"),
        Workout(name: "UTENTE 1", days: "K Days", weeks: "E Weeks"),
        Workout(name: "UTENTE 2", days: "H Days", weeks: "F Weeks")
    ]
    
    TabBarView(workouts: workoutsPreview)
}
