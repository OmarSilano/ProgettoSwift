//
//  WorkoutView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI

struct WorkoutView: View {
    let workouts: [Workout]
    
    var body: some View {
        NavigationView {
            VStack {
                // Custom toolbar
                HStack {
                    Button(action: {
                        // Help action
                    }) {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("WORKOUT")
                        .font(Font.titleLarge)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add workout action
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black)
                
                List(workouts) { workout in
                    NavigationLink(destination: Text("Dettagli di \(workout.name)")) {
                        HStack {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                            
                            VStack(alignment: .center) {
                                Text(workout.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("\(workout.days) ∞ \(workout.weeks)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.black)
                }

                .listStyle(PlainListStyle())
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
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
    
    WorkoutView(workouts: workoutsPreview)
    
}
