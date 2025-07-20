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
    @State private var groupedExercises: [MuscleGroup: [Exercise]] = [:]
    @State private var searchText = ""
    
    
    @EnvironmentObject var tabRouter: TabRouter
    
    
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
                
                Spacer()
                
                if selectedTab == "Workouts" {
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
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 300)
                } else {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Cerca un esercizio...", text: $searchText)
                                .foregroundColor(.white)
                            
                        }
                        .padding(10)
                        .background(Color("CardBackground"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        List {
                            ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                                if let exercises = filteredExercises[muscle] {
                                    Section(
                                        header: Text(muscle.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    ) {
                                        ForEach(exercises, id: \.objectID) { exercise in
                                            ExerciseRow(exercise: exercise)
                                                .listRowBackground(Color("PrimaryColor"))
                                        }
                                    }
                                    .listRowBackground(Color("PrimaryColor"))
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color("PrimaryColor").ignoresSafeArea())
                        .onAppear {
                            let manager = ExerciseManager(context: context)
                            groupedExercises = manager.fetchExercisesGroupedByMuscle()
                        }
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
