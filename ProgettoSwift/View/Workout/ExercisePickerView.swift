import SwiftUI
import CoreData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    // Output robusto: objectID degli Exercise selezionati
    var onSelect: ([NSManagedObjectID]) -> Void
    var preselectedIDs: Set<NSManagedObjectID>
    
    @State private var groupedExercises: [MuscleGroup: [Exercise]] = [:]
    @State private var selectedIDs: Set<NSManagedObjectID> = []
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
                    
                    Text("EXERCISES")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .opacity(0)
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
                
                // Lista esercizi
                List {
                    ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                        if let exercises = groupedExercises[muscle]?
                            .filter({ searchText.isEmpty || ($0.name ?? "").localizedCaseInsensitiveContains(searchText) }),
                           !exercises.isEmpty {
                            
                            Section(
                                header: Text(muscle.rawValue)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            ) {
                                ForEach(exercises, id: \.objectID) { exercise in
                                    let id = exercise.objectID
                                    let isPreselected = preselectedIDs.contains(id)
                                    let isSelected = selectedIDs.contains(id)
                                    
                                    Button {
                                        if !isPreselected { toggleSelection(for: exercise) }
                                    } label: {
                                        HStack {
                                            // Immagine (supporta sia asset name che file path)
                                            if let uiImage = exerciseImage(for: exercise) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(6)
                                                    .onTapGesture { selectedExerciseForDetail = exercise }
                                            } else {
                                                Rectangle()
                                                    .fill(Color.gray)
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(6)
                                                    .onTapGesture { selectedExerciseForDetail = exercise }
                                            }
                                            
                                            // Nome esercizio
                                            Text(exercise.name ?? "Unnamed")
                                                .foregroundColor(.white)
                                                .font(.body)
                                                .padding(.leading, 8)
                                            
                                            Spacer()
                                            
                                            // Check
                                            if selectedIDs.contains(exercise.objectID) || preselectedIDs.contains(exercise.objectID) {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(red: 46/255, green: 44/255, blue: 44/255))
                                        )
                                        .opacity(isPreselected ? 0.5 : 1.0)
                                    }
                                    .disabled(isPreselected)
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
                        .mapValues { $0.filter { !$0.isBanned } }
                    selectedIDs = []
                }
                
            }
        }
        .sheet(item: $selectedExerciseForDetail) { exercise in
            ExerciseDetailView(objectID: exercise.objectID)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !selectedIDs.isEmpty {
                VStack(spacing: 0) {
                    Divider().background(Color.gray.opacity(0.5))

                    Button(action: {
                        onSelect(Array(selectedIDs))
                        dismiss()
                    }) {
                        Text("ADD EXERCISES (\(selectedIDs.count))")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                .background(Color("PrimaryColor").ignoresSafeArea())
            }
        }
        .animation(.easeInOut, value: selectedIDs.isEmpty)
    }
    
    // MARK: - Helpers
    private func toggleSelection(for exercise: Exercise) {
        let id = exercise.objectID
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
    
    private func exerciseImage(for exercise: Exercise) -> UIImage? {
        guard let path = exercise.pathToImage, !path.isEmpty else { return nil }
        // Prova come file path
        if path.contains("/") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
               let img = UIImage(data: data) {
                return img
            }
        }
        // Fallback come nome asset
        return UIImage(named: path)
    }
}
