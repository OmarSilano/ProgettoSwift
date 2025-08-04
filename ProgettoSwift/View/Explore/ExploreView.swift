import SwiftUI

struct CategoryCard: Identifiable {
    let id = UUID()
    let category: Category
    let imageName: String
    let description: String
}

struct ExploreView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var selectedTab = "Workouts"
    @State private var explorePath = NavigationPath()
    @State private var searchText = ""
    @State private var refreshTrigger = false

    
    
    @EnvironmentObject var tabRouter: TabRouter
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
        animation: .default
    )
    private var allExercises: FetchedResults<Exercise>
    private var groupedExercises: [MuscleGroup: [Exercise]] {
        Dictionary(
            grouping: allExercises.compactMap { exercise in
                guard let _ = exercise.muscleGroupEnum else { return nil }
                return exercise
            },
            by: { $0.muscleGroupEnum! }
        )
    }

    
    private let categories: [CategoryCard] = Category.allCases.map {
        CategoryCard(category: $0, imageName: $0.rawValue, description: "Explore \($0.rawValue) workouts.")
    }
    
    init() {
        let segmentedAppearance = UISegmentedControl.appearance()
        segmentedAppearance.selectedSegmentTintColor = UIColor(named: "SecondaryColor")
        segmentedAppearance.backgroundColor = UIColor(named: "TabBarColor")?.withAlphaComponent(0.9)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "FourthColor")], for: .normal)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "PrimaryColor")], for: .selected)
    }
    
    private var filteredExercises: [MuscleGroup: [Exercise]] {
        let normalizedQuery = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        // Se query vuota → mostra tutto
        guard !normalizedQuery.isEmpty else { return groupedExercises }
        
        var filtered: [MuscleGroup: [Exercise]] = [:]
        
        for (muscle, exercises) in groupedExercises {
            let matching = exercises.filter { exercise in
                let exerciseName = (exercise.name ?? "").lowercased()
                return exerciseName.contains(normalizedQuery)
            }
            if !matching.isEmpty {
                filtered[muscle] = matching
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack(path: $explorePath) {
            VStack(spacing: 20) {
                Text("EXPLORE")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("FourthColor"))
                    .padding(.top, 20)
                
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Workouts").tag("Workouts")
                    Text("Exercises").tag("Exercises")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                
                if selectedTab == "Workouts" {
                    
                    Spacer()
                    
                    TabView {
                        ForEach(categories) { card in
                            Button {
                                explorePath.append(card.category)
                            } label: {
                                VStack(spacing: 10) {
                                    Image(card.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 200)
                                        .clipped()
                                        .cornerRadius(20)
                                    
                                    Text(card.category.rawValue)
                                        .font(.title2)
                                        .foregroundColor(Color("SecondaryColor"))
                                    
                                    Text(card.description)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Spacer().frame(height: 50)
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 300)
                } else {
                    VStack(spacing: 0) {
                        // Search bar in stile ExercisePickerView
                        HStack {
                            ZStack(alignment: .leading) {
                                if searchText.isEmpty {
                                    Text("Cerca un esercizio...")
                                        .foregroundColor(Color("SubtitleColor"))
                                        .padding(.horizontal, 14)
                                }

                                TextField("", text: $searchText)
                                    .foregroundColor(.white)
                                    .accentColor(Color("SecondaryColor"))
                                    .padding(10)
                            }
                            .background(Color("ThirdColor"))
                            .cornerRadius(10)

                            if !searchText.isEmpty {
                                Button("Cancel") {
                                    searchText = ""
                                }
                                .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color("PrimaryColor"))

                        // Lista esercizi
                        List {
                            ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                                if let exercises = filteredExercises[muscle], !exercises.isEmpty {
                                    Section(
                                        header: Text(muscle.rawValue)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    ) {
                                        ForEach(exercises, id: \.objectID) { exercise in
                                            NavigationLink {
                                                ExerciseDetailView(exercise: exercise)
                                                    .onDisappear {
                                                        refreshTrigger.toggle()
                                                    }
                                            } label: {
                                                HStack {
                                                    // Immagine
                                                    if exercise.isBanned {
                                                        Image(systemName: "lock.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .foregroundColor(Color(red: 46/255, green: 44/255, blue: 44/255))
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(6)
                                                    } else if let imageName = exercise.pathToImage,
                                                              let uiImage = UIImage(named: imageName) {
                                                        Image(uiImage: uiImage)
                                                            .resizable()
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(6)
                                                    } else {
                                                        Rectangle()
                                                            .fill(Color.gray)
                                                            .frame(width: 40, height: 40)
                                                            .cornerRadius(6)
                                                    }

                                                    
                                                    // Nome esercizio
                                                    Text(exercise.name ?? "Unnamed")
                                                        .foregroundColor(.white)
                                                        .opacity(exercise.isBanned ? 0.4 : 1.0)
                                                        .font(.body)
                                                        .padding(.leading, 8)
                                                    
                                                    Spacer()
                                                }
                                                .padding(8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(
                                                                    exercise.isBanned
                                                                        ? Color(red: 13/255, green: 13/255, blue: 13/255)
                                                                        : Color(red: 46/255, green: 44/255, blue: 44/255)
                                                                )                                                )
                                            }
                                            .listRowBackground(
                                                exercise.isBanned
                                                    ? Color(red: 13/255, green: 13/255, blue: 13/255)
                                                    : Color(red: 46/255, green: 44/255, blue: 44/255)
                                                )
                                        }
                                    }
                                    .listRowBackground(Color("PrimaryColor"))
                                }
                            }
                        }
                        .id(refreshTrigger)
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        .background(Color("PrimaryColor").ignoresSafeArea())
                    }
                }

                
                Spacer()
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
            .navigationDestination(for: Category.self) { category in
                ExploreWorkoutsView(workoutCategory: category, explorePath: $explorePath)
                    .environmentObject(tabRouter)
                    .navigationBarHidden(true)
            }
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout, explorePath: $explorePath)
                    .navigationBarHidden(true)
            }
        }
        .navigationBarHidden(true)
        .background(Color("PrimaryColor").ignoresSafeArea())
    }
}






#Preview {
    ExploreView()
}
