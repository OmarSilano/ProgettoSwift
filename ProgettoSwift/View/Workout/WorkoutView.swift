//
//  WorkoutView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//

import SwiftUI
import CoreData

struct WorkoutView: View {
    @FetchRequest(
        entity: Workout.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Workout.name, ascending: true)],
        predicate: NSPredicate(format: "isSaved == true")
    ) private var workouts: FetchedResults<Workout>
    @State private var selectedWorkout: Workout?
    @State private var showActionSheet = false
    @Environment(\.managedObjectContext) private var context

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: – Header
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
        .font(.title2)
        .bold()
        .foregroundColor(Color("FourthColor"))

    Spacer()

    // Qui puoi scegliere se mettere NavigationLink o Button per aggiungere workout
    NavigationLink(destination: AddWorkoutView()) {
        Image(systemName: "plus")
            .resizable()
            .frame(width: 22, height: 22)
            .foregroundColor(Color("FourthColor"))
    }
}


                .padding()
                .background(Color("PrimaryColor"))
                
                // MARK: – Lista workout salvati
                if workouts.isEmpty {
                    Spacer()
                    Text("No saved workouts yet.")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink(destination: SavedWorkoutDetailView(workout: workout)) {
                                WorkoutRow(workout: workout)
                            }
                            .contextMenu {
                                Button("Replicate and Improve") { /* Da fare */ }
                                Button("Edit") { /* Da fare */ }
                                Button("Share") { /* Da fare */ }
                                Button("Delete", role: .destructive) {
                                    deleteWorkout(workout)
                                }
                            }
                            .listRowBackground(Color("PrimaryColor"))
                        }
                    }

                    .listStyle(PlainListStyle())
                }
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar(.visible, for: .tabBar)
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        let manager = WorkoutManager(context: context)
        manager.deleteWorkout(workout)
    }
}

// MARK: – Cellula riga singola
private struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 12) {
            
            if let imgPath = workout.pathToImage, !imgPath.isEmpty {        //se è un'immagine caricata
                if let uiImage = UIImage(contentsOfFile: imgPath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                        .clipped()
                } else if let img = workout.pathToImage, !img.isEmpty {
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                        .clipped()
                }

            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("FourthColor"))
            }


            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name ?? "Unnamed")
                    .foregroundColor(Color("FourthColor"))
                    .font(.headline)
                
                Text("\(workout.days) days • \(workout.weeks) weeks")
                    .font(.subheadline)
                    .foregroundColor(Color("SubtitleColor"))
            }
        }
        .padding(.vertical, 6)
    }
}
