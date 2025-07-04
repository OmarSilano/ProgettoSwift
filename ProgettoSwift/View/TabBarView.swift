//
//  NewTabView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {
                    ExploreView()
                        .tabItem {
                            
                            Image(systemName: "safari")
                            Text("EXPLORE")
                            
                        }
                    
                    WorkoutView()
                        .tabItem {
                            
                            Image(systemName: "dumbbell")
                            Text("WORKOUT")
                            
                        }
                    
                    StatsView()
                        .tabItem {
                            
                            Image(systemName: "chart.xyaxis.line")
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
    TabBarView()
}
