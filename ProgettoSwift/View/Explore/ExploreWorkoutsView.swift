import SwiftUI

struct WorkoutCardView: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "dumbbell.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("FourthColor"))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name ?? "Unnamed")
                    .foregroundColor(.white)
                    .font(.headline)
                Text("\(workout.weeks) weeks • \(workout.days ?? 0) days")
                    .foregroundColor(Color("SubtitleColor"))
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ExploreWorkoutsView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode

    let workoutCategory: Category
    @State private var selectedDifficulty: Difficulty = .beginner
    @State private var workouts: [Workout] = []

    private let workoutManager: WorkoutManager

    init(workoutCategory: Category) {
        self.workoutCategory = workoutCategory
        self.workoutManager = WorkoutManager(context: PersistenceController.shared.container.viewContext)

        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor(named: "SecondaryColor")
        appearance.backgroundColor = UIColor(named: "TabBarColor")?.withAlphaComponent(0.9)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "FourthColor") ?? .gray], for: .normal)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "PrimaryColor") ?? .white], for: .selected)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header personalizzato
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title3)
                }

                Spacer()

                Text(workoutCategory.rawValue)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                Button {
                    // Help action
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color("FourthColor"))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Picker difficoltà
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .tint(Color("SecondaryColor"))

            // Lista workout
            if workouts.isEmpty {
                Spacer()
                Text("No workouts available.")
                    .foregroundColor(.gray)
                    .italic()
                Spacer()
            } else {
                List {
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout).navigationBarHidden(true)) {
                            WorkoutCardView(workout: workout)
                        }
                        .listRowBackground(Color("PrimaryColor"))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .onAppear { loadWorkouts() }
        .onChange(of: selectedDifficulty) { _ in loadWorkouts() }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
    }

    private func loadWorkouts() {
        let all = workoutManager.fetchWorkoutByCategory(workoutCategory)
        self.workouts = all.filter {
            $0.difficulty == selectedDifficulty.rawValue && $0.isSaved == false
        }
    }
}

