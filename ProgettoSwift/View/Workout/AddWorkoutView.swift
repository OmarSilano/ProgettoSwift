import SwiftUI
import CoreData

struct AddWorkoutView: View {
    // Il parent (store reale)
    @ObservedObject var workoutDraft: Workout
    let childContext: NSManagedObjectContext
    @Environment(\.dismiss) private var dismiss
    private let parentContext: NSManagedObjectContext

    // UI state invariati (per mantenere la stessa UI)
    @State private var workoutName = "New Workout"
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberWeeks = ""
    @State private var expandedDayID: NSManagedObjectID? = nil
    @State private var dayBeingEdited: WorkoutDay? = nil
    @State private var pathToImage: String? = nil
    @State private var showPermissionAlert = false

    // Manager che usano SEMPRE il child
    private var workoutManager: WorkoutManager { WorkoutManager(context: childContext) }
    private var workoutDayManager: WorkoutDayManager { WorkoutDayManager(context: childContext) }
    private var workoutDayDetailManager: WorkoutDayDetailManager { WorkoutDayDetailManager(context: childContext) }
    private var exerciseManager: ExerciseManager { ExerciseManager(context: childContext) }
    
    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        
        // 1) child context
        let child = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        child.parent = parentContext
        child.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        child.automaticallyMergesChangesFromParent = true
        self.childContext = child
        
        // 2) draft nel child
        let draft = Workout(context: child)
        draft.name = "New Workout"
        draft.isSaved = false
        _workoutDraft = ObservedObject(initialValue: draft)
    }

    // MARK: - Body (UI invariata)
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top bar (identica)
                HStack {
                    Button {
                        // Chiudiamo: il child non salvato viene scartato
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title3)
                    }

                    Spacer()

                    Text("CREATE WORKOUT")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Save") {
                        saveAll()
                        dismiss()
                    }
                    .foregroundColor(Color("FourthColor"))
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // TextField WorkoutName + X
                HStack {
                    TextField("Workout Name", text: $workoutName)
                        .onChange(of: workoutName) { _, newValue in
                            workoutDraft.name = newValue
                        }
                        .foregroundColor(Color("FourthColor"))
                        .font(.headline)

                    if !workoutName.isEmpty {
                        Button {
                            workoutName = ""
                            workoutDraft.name = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color("SecondaryColor"))
                        }
                    }
                }
                .padding(.horizontal)
                .padding()
                .background(Color("ThirdColor"))
                .cornerRadius(8)

                // Image picker
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        Rectangle()
                            .fill(Color("ThirdColor"))
                            .frame(height: 200)
                            .cornerRadius(10)
                    }

                    Button {
                        Task {
                            let granted = await Permissions().requestGalleryPermission()
                            if granted {
                                isShowingImagePicker = true
                            } else {
                                showPermissionAlert = true
                            }
                        }
                    } label: {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .frame(width: 30, height: 25)
                            .foregroundColor(Color("PrimaryColor"))
                            .padding(8)
                            .background(Color("SecondaryColor"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                // Weeks input + Days count
                HStack {
                    Text("\(daysArray.count) Days")
                        .foregroundColor(Color("FourthColor"))
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("∞")
                            .foregroundColor(Color("FourthColor"))
                            .font(.headline)

                        TextField("0", text: $numberWeeks)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 50)
                            .padding(6)
                            .background(Color("ThirdColor"))
                            .cornerRadius(8)
                            .foregroundColor(Color("FourthColor"))
                            .onChange(of: numberWeeks) { newValue in
                                numberWeeks = newValue.filter { "0123456789".contains($0) }
                            }

                        Text("Weeks")
                            .foregroundColor(Color("FourthColor"))
                            .font(.headline)
                    }
                }
                .padding(.horizontal, 30)

                Divider().background(Color("ThirdColor"))

                // Lista giorni
                if !daysArray.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(daysArray, id: \.objectID) { day in
                            WorkoutDayRow_CoreData(
                                day: day,
                                expandedDayID: $expandedDayID,
                                onDelete: {
                                    childContext.delete(day)
                                },
                                onEdit: {
                                    dayBeingEdited = day
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                // Add day button
                Button {
                    if daysArray.count < 7 {
                        _ = workoutDayManager.createWorkoutDay(
                            isCompleted: false,
                            name: "\(daysArray.count + 1)° Day",
                            muscles: [],
                            workout: workoutDraft
                        )
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Day")
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .padding()
                    .background(Color("SecondaryColor"))
                    .cornerRadius(25)
                }
                .padding(.top)

                Spacer(minLength: 50)
            }
            .padding(.top)
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let img = newImage {
                handleImageSelected(img)
            }
        }
        .sheet(item: $dayBeingEdited) { day in
            AddWorkoutDayView(
                day: day,
                context: childContext,
                onSave: { updated in
                    updated.updateMusclesFromDetails()
                    dayBeingEdited = nil
                }
            )
        }
        .navigationBarBackButtonHidden(true)
        .alert("Accesso alla galleria negato", isPresented: $showPermissionAlert) {
            Button("Apri Impostazioni") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Abilita l’accesso alla galleria dalle impostazioni per selezionare un'immagine.")
        }
        
    }

    // MARK: - Helpers

    // Giorni del workout ordinati
    private var daysArray: [WorkoutDay] {
        let set = (workoutDraft.workoutDay as? Set<WorkoutDay>) ?? []
        // Mantieni ordinamento alfabetico sul nome
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    // Salva immagine in Documents/Images e collega il path al draft
    private func handleImageSelected(_ image: UIImage) {
        let imageName = UUID().uuidString + ".jpg"
        if let savedPath = saveImageToDocuments(image, imageName: imageName) {
            pathToImage = savedPath
            print("Immagine in salvata in \(savedPath)")
            workoutDraft.pathToImage = savedPath
        }
    }

    // Salvataggio atómico: Workout + Days + Details
    private func saveAll() {
        // Valori finali dal form
        let finalName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        workoutDraft.name = finalName.isEmpty ? "New Workout" : finalName
        
        workoutDraft.weeks = Int16(numberWeeks) ?? 0
        workoutDraft.days = Int16(daysArray.count)
        workoutDraft.isSaved = true
        // aggiorna i muscoli per ogni day
        daysArray.forEach { $0.updateMusclesFromDetails() }

        do {
            try childContext.save()     // child -> parent
            try parentContext.save()    // parent -> store
        } catch {
            print("Errore salvataggio workout:", error)
        }
    }
}


// MARK: - Editor WorkoutDay
private struct AddWorkoutDayView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var day: WorkoutDay
    let context: NSManagedObjectContext
    var onSave: (WorkoutDay) -> Void

    @State private var newName: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {

                // Top bar custom
                HStack {
                    Button("Cancel") {
                        onSave(day)
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Text("EDIT DAY")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Save") {
                        day.name = newName
                        day.updateMusclesFromDetails()
                        onSave(day)
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                TextField("Day name", text: $newName)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color("ThirdColor"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .onAppear { newName = day.name ?? "" }

                if day.sortedDetails.isEmpty {
                    Text("No exercises yet")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(day.sortedDetails, id: \.objectID) { d in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(d.exercise?.name ?? "Exercise")
                                            .foregroundColor(.white)
                                            .font(.headline)

                                        Spacer()

                                        Text(d.typology?.name ?? "Method")
                                            .foregroundColor(Color("SubtitleColor"))
                                            .font(.subheadline)
                                    }
                                }

                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                            .listRowBackground(Color("ThirdColor"))
                        }
                        .onDelete { idx in
                            idx.map { day.sortedDetails[$0] }.forEach(context.delete)
                            day.updateMusclesFromDetails()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color("PrimaryColor"))
                }
                
                Button {
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Exercise")
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(20)
                }
                .padding()

                Spacer()
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
}

