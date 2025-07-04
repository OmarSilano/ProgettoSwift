//
//  NewTabView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct TabBar: View {
    
    var body: some View {
        TabView {
                    ExploreView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("EXPLORE")
                        }
                    
                    WorkoutView()
                        .tabItem {
                            Image(systemName: "dumbbell")
                            Text("WORKOUT")
                        }
                    
                    StatsView()
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("STATS")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("SETTINGS")
                        }
                }
    }
}


#Preview {
    TabBar()
}
