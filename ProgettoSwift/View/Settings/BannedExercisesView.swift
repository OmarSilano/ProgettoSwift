import SwiftUI
import CoreData

struct BannedExercisesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    var onSelect: ([AddWorkoutView.ExercisePreview]) -> Void

    @State private var groupedExercises: [MuscleGroup: [Exercise]] = [:]
    @State private var selectedExercises: Set<UUID> = []
    @State private var searchText = ""
    @State private var selectedExerciseForDetail: Exercise? = nil


    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }

                    Spacer()

                    Text("BANNED EXERCISES")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Slot vuoto per simmetria con bottone sinistro così da rendere il titolo centrato
                    Image(systemName: "xmark")
                        .opacity(0) // invisibile ma occupa spazio
                        .font(.title2)
                }
                .padding()
                .background(Color("PrimaryColor"))


                // Search bar
                HStack {
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Search")
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

                //Se non ci sono esercizi bannati, visualizzo solo un messaggio
                if groupedExercises.values.flatMap({ $0 }).isEmpty {
                    VStack {
                        Spacer()
                        Text("No banned exercises found.")
                            .foregroundColor(.gray)
                            .italic()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("PrimaryColor"))
                }


                // Lista esercizi bannati
                List {
                    ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                        if let exercises = groupedExercises[muscle]?
                            .filter({ searchText.isEmpty || $0.name?.localizedCaseInsensitiveContains(searchText) == true }),
                           !exercises.isEmpty {

                            Section(
                                header: Text(muscle.rawValue)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            ) {
                                ForEach(exercises, id: \.objectID) { exercise in
                                    Button {
                                        toggleSelection(for: exercise)
                                    } label: {
                                        HStack {
                                            // Immagine
                                            if let imageName = exercise.pathToImage,
                                               let uiImage = UIImage(named: imageName) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(6)
                                                    .onTapGesture {
                                                        selectedExerciseForDetail = exercise
                                                    }
                                            } else {
                                                Rectangle()
                                                    .fill(Color.gray)
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(6)
                                                    .onTapGesture {
                                                        selectedExerciseForDetail = exercise
                                                    }
                                            }

                                            // Nome esercizio
                                            Text(exercise.name ?? "Unnamed")
                                                .foregroundColor(.white)
                                                .font(.body)
                                                .padding(.leading, 8)

                                            Spacer()

                                            // Check
                                            if selectedExercises.contains(exercise.id!) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color(red: 46/255, green: 44/255, blue: 44/255))
                                            )
                                    }
                                    .listRowBackground(Color(red: 46/255, green: 44/255, blue: 44/255))
                                }
                            }
                            .listRowBackground(Color("PrimaryColor"))
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color("PrimaryColor").ignoresSafeArea())
                .onAppear {
                    let manager = ExerciseManager(context: context)
                    groupedExercises = manager.fetchExercisesGroupedByMuscle()
                        .mapValues { $0.filter { $0.isBanned } }

                }
            }

            // Pulsante overlay in basso
            if !selectedExercises.isEmpty {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.5))
                    Button(action: {
                        let allExercises: [Exercise] = groupedExercises
                            .flatMap { $0.value }

                        let filtered: [Exercise] = allExercises
                            .filter { selectedExercises.contains($0.id!) }

                        let selected: [AddWorkoutView.ExercisePreview] = filtered.map { ex in
                            AddWorkoutView.ExercisePreview(
                                id: ex.id ?? UUID(),
                                name: ex.name ?? "Unnamed",
                                muscle: ex.muscle ?? "Unknown",
                                typology: nil
                            )
                        }
                        onSelect(selected)
                        dismiss()
                    }) {
                        Text("UNBAN (\(selectedExercises.count))")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                    .background(Color("PrimaryColor").ignoresSafeArea(edges: .bottom))
                }
                .transition(.move(edge: .bottom))
            }
        }
        .sheet(item: $selectedExerciseForDetail) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }


    private func toggleSelection(for exercise: Exercise) {
        guard let id = exercise.id else { return }
        if selectedExercises.contains(id) {
            selectedExercises.remove(id)
        } else {
            selectedExercises.insert(id)
        }
    }
    
}
