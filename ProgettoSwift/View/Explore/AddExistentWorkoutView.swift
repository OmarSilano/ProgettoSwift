//
//  WorkoutView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import Foundation
import CoreData

struct AddExistentWorkoutView: View {
    
    let workout: Workout
    
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
                    
                    Text(workout.name!)
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
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Image(systemName: "photo")
                    .resizable()
                    .frame(width:350, height: 350)
                    .foregroundColor(Color("FourthColor"))
                
                HStack{
                    Text("\(workout.days) Days")
                        .font(Font.bodyRegular)
                        .foregroundColor(Color("FourthColor"))
                    Spacer()
                    
                    Text("􀯠 \(workout.weeks) Weeks")
                        .font(Font.bodyRegular)
                        .foregroundColor(Color("FourthColor"))
                }
                
            }
            .background(Color("PrimaryColor").edgesIgnoringSafeArea(.all))
        }
    }
}
    


/*
#Preview {
    
    let workoutCategory: String = "HYPERTROPHY"
    
    let workout = Workout(context: <#T##NSManagedObjectContext#>, name: <#T##String#>, weeks: <#T##Int16#>, imagePath: <#T##String?#>, difficulty: <#T##Difficulty#>)
    
    AddExistentWorkoutView(workout: workout)
    
}
*/
