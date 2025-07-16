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
        
        let manager = WorkoutManager(context: context)
        
        let workouts = manager.fetchSavedWorkouts()
        
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

                    NavigationLink(destination: AddWorkoutView()) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color("FourthColor"))
                    }
                }

                .padding()
                .background(Color("PrimaryColor"))
                
                List(workouts) { workout in
                    NavigationLink(destination: Text("Dettagli di \(workout.name!)")) {
                        HStack {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                                .foregroundColor(Color("FourthColor"))
                            
                            VStack(alignment: .center) {
                                Text(workout.name!)
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
    
    WorkoutView()
    
}
