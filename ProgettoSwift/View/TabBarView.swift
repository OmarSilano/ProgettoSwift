//
//  NewTabView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Int = 0 //mi indica quale tabItem è selezionato (per poter mettere il fill dei symbols)
    
    
    /*STYLING TABBAR*/
    init() {

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
            
            WorkoutView()
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
    
    TabBarView()
    
}
