//
//  WorkoutView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct ExploreWorkoutsView: View {
    
    let workoutCategory: String
    let workouts: [Workout]
    @State private var selectedTab = "Beginner"
    
    var filteredWorkouts: [Workout] {
            workouts.filter { $0.difficulty == selectedTab }
        }
    
    init(workoutCategory: String, workouts: [Workout]) {
        
        self.workouts = workouts
        self.workoutCategory = workoutCategory
        
            let segmentedAppearance = UISegmentedControl.appearance()
            segmentedAppearance.selectedSegmentTintColor = UIColor(named: "SecondaryColor")
            segmentedAppearance.backgroundColor = UIColor(named: "TabBarColor")?.withAlphaComponent(0.9)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "FourthColor")], for: .normal)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "PrimaryColor")], for: .selected)
        }
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom toolbar
                HStack {
                    Button(action: {
                        // Help action
                    }) {
                        Image(systemName: "lessthan")
                            .resizable()
                            .frame(width: 15, height: 20)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(workoutCategory)
                        .font(Font.titleLarge)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add workout action
                    }) {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("FourthColor"))
                    }
                }
                .padding()
                
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Beginner")
                        .tag("Beginner")
                    Text("Intermediate").tag("Intermediate")
                    Text("Advanced").tag("Advanced")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .tint(Color("SecondaryColor"))
                
                
                List(filteredWorkouts) { workout in
                    NavigationLink(destination: Text("Dettagli di \(workout.name)")) {
                        HStack {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                                .foregroundColor(Color("FourthColor"))
                            
                            VStack(alignment: .center) {
                                Text(workout.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("\(workout.days) ∞ \(workout.weeks)")
                                    .font(.subheadline)
                                    .foregroundColor(Color("SubtitleColor"))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color("PrimaryColor"))
                }

                .listStyle(PlainListStyle())
            }
            .background(Color("PrimaryColor").edgesIgnoringSafeArea(.all))
        }
    }
}


#Preview {
    
    let workoutCategory: String = "HYPERTROPHY"
    
    let workoutsPreview: [Workout] = [
        Workout(name: "PIRAMIDALE A", days: "X Days", weeks: "A Weeks", difficulty: "Beginner"),
        Workout(name: "PIRAMIDALE INVERSO B", days: "Y Days", weeks: "B Weeks", difficulty: "Beginner"),
        Workout(name: "10X4 C", days: "Z Days", weeks: "C Weeks", difficulty: "Beginner"),
        Workout(name: "8X4 D", days: "W Days", weeks: "D Weeks", difficulty: "Intermediate"),
        Workout(name: "UTENTE 1", days: "K Days", weeks: "E Weeks", difficulty: "Advanced"),
        Workout(name: "UTENTE 2", days: "H Days", weeks: "F Weeks", difficulty: "Advanced")
    ]
    
    ExploreWorkoutsView(workoutCategory: workoutCategory, workouts: workoutsPreview)
    
}
