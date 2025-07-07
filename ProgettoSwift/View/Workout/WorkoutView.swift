//
//  WorkoutView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import Foundation
import CoreData

struct WorkoutView: View {
    @Environment(\.managedObjectContext) var context
    
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
                            .foregroundColor(Color("FourthColor"))
                    }
                    
                    Spacer()
                    
                    Text("WORKOUT")
                        .font(Font.titleLarge)
                        .bold()
                        .foregroundColor(Color("FourthColor"))
                    
                    Spacer()
                    
                    Button(action: {
                        // Add workout action
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("FourthColor"))
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
                                .foregroundColor(Color("FourthColor"))
                            
                            VStack(alignment: .center) {
                                Text(workout.name)
                                    .font(.headline)
                                    .foregroundColor(Color("FourthColor"))
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
    
    let workoutsPreview: [Workout] = [
        Workout(name: "PIRAMIDALE A", days: "X Days", weeks: "A Weeks", difficulty: "Beginner"),
        Workout(name: "PIRAMIDALE INVERSO B", days: "Y Days", weeks: "B Weeks", difficulty: "Beginner"),
        Workout(name: "10X4 C", days: "Z Days", weeks: "C Weeks", difficulty: "Beginner"),
        Workout(name: "8X4 D", days: "W Days", weeks: "D Weeks", difficulty: "Intermediate"),
        Workout(name: "UTENTE 1", days: "K Days", weeks: "E Weeks", difficulty: "Advanced"),
        Workout(name: "UTENTE 2", days: "H Days", weeks: "F Weeks", difficulty: "Advanced")
    ]
    
    WorkoutView(workouts: workoutsPreview)
    
}
