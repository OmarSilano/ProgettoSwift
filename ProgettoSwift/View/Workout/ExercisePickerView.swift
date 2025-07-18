import SwiftUI
import CoreData

struct ExercisePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    var onSelect: ([AddWorkoutView.ExercisePreview]) -> Void

    @State private var groupedExercises: [MuscleGroup: [Exercise]] = [:]
    @State private var selectedExercises: Set<UUID> = []
    @State private var searchText = ""
    @State private var selectedExerciseForDetail: Exercise? = nil


    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }

                Text("EXERCISES")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)

                Spacer()
            }
            .background(Color("PrimaryColor"))

            // Search bar
            HStack {
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(Color("ThirdColor"))
                    .cornerRadius(10)
                    .foregroundColor(.white)

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
                    if let exercises = groupedExercises[muscle]?
                        .filter({ searchText.isEmpty || $0.name?.localizedCaseInsensitiveContains(searchText) == true }),
                       !exercises.isEmpty {

                        Section(
                            header: Text(muscle.rawValue)
                                .font(.headline)
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
                                }
                                .listRowBackground(Color("PrimaryColor"))
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
                    .mapValues { $0.filter { !$0.isBanned } }
            }

            // Pulsante Add
            if !selectedExercises.isEmpty {
                Button(action: {
                    let selected: [AddWorkoutView.ExercisePreview] = groupedExercises
                        .flatMap { $0.value }
                        .filter { selectedExercises.contains($0.id!) }
                        .map {
                            AddWorkoutView.ExercisePreview(
                                name: $0.name ?? "Unnamed",
                                muscle: $0.muscle ?? "Unknown"
                            )
                        }
                    onSelect(selected)
                    dismiss()
                }) {
                    Text("ADD EXERCISES")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
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

    private func openDetail(for exercise: Exercise) {
        // TODO: Naviga a una schermata di dettaglio
        print("🧾 Apri dettaglio per \(exercise.name ?? "Unnamed")")
    }
}
