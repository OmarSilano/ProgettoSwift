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
    @State private var workoutToEdit: Workout? = nil
    @State private var shareURL: URL?
    @State private var showInfoSheet = false

    
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: – Header
                ZStack {
                    HStack {
                        Button(action: {
                            showInfoSheet = true
                        }) {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color("FourthColor"))
                        }
                        Spacer()
                        NavigationLink(destination: AddWorkoutView()) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color("FourthColor"))
                        }
                    }
                    .padding(.horizontal)

                    Text("WORKOUT")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("FourthColor"))
                }
                .padding(.top, 20)
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
                            NavigationLink(destination: SavedWorkoutDetailView(workoutID: workout.objectID)) {
                                WorkoutRow(workout: workout)
                            }
                            .contextMenu {
                                Button("Replicate and Improve") { /* Da fare */ }
                                Button("Edit") {
                                    workoutToEdit = workout
                                }
                                Button("Share") {
                                        shareWorkout(workout)
                                    }
                                Button("Delete", role: .destructive) {
                                    deleteWorkout(workout)
                                }
                            }
                            .listRowBackground(Color("PrimaryColor"))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .id(UUID())
                }
            }
            .sheet(item: $shareURL) { url in
                ShareSheet(items: [url]) {
                    shareURL = nil
                }
            }

            .background(Color("PrimaryColor").ignoresSafeArea())
            .navigationBarHidden(true)
            .toolbar(.visible, for: .tabBar)
            .navigationDestination(isPresented: Binding(
                get: { workoutToEdit != nil },
                set: { isActive in
                    if !isActive { workoutToEdit = nil }
                }
            )) {
                if let workout = workoutToEdit {
                    EditWorkoutView(workout: workout)
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            WorkoutInfoSheetView()
        }

        
    }
    
    private func shareWorkout(_ workout: Workout) {
        let plainText = workout.toPlainText()  // ✅ ora usa la versione pulita
        if let url = saveAsTextFile(plainText, filename: workout.name ?? "Workout") {
            print("✅ File pronto per la condivisione: \(url.path)")
            shareURL = url
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
        HStack(spacing: 16) {
            // Immagine
            if let imgPath = workout.pathToImage,
                !imgPath.isEmpty,
               FileManager.default.fileExists(atPath: imgPath),
                let uiImage = UIImage(contentsOfFile: imgPath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                        .clipped()
                } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("FourthColor"))
                    .background(Color("ThirdColor"))
                    .cornerRadius(10)
            }

            // Testi
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name ?? "Unnamed")
                    .foregroundColor(Color("FourthColor"))
                    .font(.headline)
                    .lineLimit(1)

                Text("\(workout.days) days • \(workout.weeks) weeks")
                    .font(.subheadline)
                    .foregroundColor(Color("SubtitleColor"))
            }

            Spacer()
        }
        .padding(12)
        .cornerRadius(12)
    }
}

// MARK: - URL Identifiable (per .sheet(item:))
extension URL: Identifiable {
    public var id: String { absoluteString }
}
