import SwiftUI
import CoreData

struct AddWorkoutView: View {
    // Parent (store reale)
    private let parentContext: NSManagedObjectContext
    // Child 
    let childContext: NSManagedObjectContext

    // Draft nel child
    @ObservedObject var workoutDraft: Workout

    @Environment(\.dismiss) private var dismiss

    // UI state (invariata)
    @State private var workoutName = "New Workout"
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberWeeks = ""
    @State private var expandedDayID: NSManagedObjectID? = nil
    @State private var dayBeingEdited: WorkoutDay? = nil
    @State private var pathToImage: String? = nil
    @State private var showPermissionAlert = false

    // Presentazioni sheet
    @State private var isPresentingNewDayEditor = false
    @State private var isEditingDay = false

    // Manager (sul child)
    private var workoutManager: WorkoutManager { WorkoutManager(context: childContext) }

    // Fetch reattivo dei giorni nel child, filtrati per il draft
    @FetchRequest private var fetchedDays: FetchedResults<WorkoutDay>

    // MARK: - Init
    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext

        // 1) child context
        let child = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        child.parent = parentContext
        child.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        child.automaticallyMergesChangesFromParent = true
        self.childContext = child

        // 2) crea il draft nel child
        let draft = Workout(context: child,
                            name: "New Workout",
                            weeks: 0,
                            imagePath: nil,
                            difficulty: .beginner,
                            category: nil,
                            isSaved: false)
        _workoutDraft = ObservedObject(initialValue: draft)

        // 3) fetch giorni del draft
        _fetchedDays = FetchRequest(
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            predicate: NSPredicate(format: "workout == %@", draft)
        )
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button { dismiss() } label: {
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

                // Nome workout
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

                // Immagine
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
                            if granted { isShowingImagePicker = true }
                            else { showPermissionAlert = true }
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

                // Weeks + Days
                HStack {
                    Text("\(daysForUI.count) Days")
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
                if !daysForUI.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(daysForUI, id: \.objectID) { day in
                            WorkoutDayRow_CoreData(
                                day: day,
                                expandedDayID: $expandedDayID,
                                onDelete: {
                                    // Delete staged in child (non tocca lo store finché non salviamo il parent)
                                    childContext.delete(day)
                                },
                                onEdit: {
                                    dayBeingEdited = day
                                    isEditingDay = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    isPresentingNewDayEditor = true
                } label: {
                    HStack { Image(systemName: "plus"); Text("Add Day") }
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
        .onChange(of: selectedImage) { img in
            if let image = img { handleImageSelected(image) }
        }
        // EDIT Day esistente (sul child)
        .sheet(isPresented: $isEditingDay) {
            if let day = dayBeingEdited {
                EditWorkoutDayView(
                    day: day,
                    onClose: {
                        isEditingDay = false
                        dayBeingEdited = nil
                    }
                )
                .environment(\.managedObjectContext, childContext)
            }
        }
        // CREATE Day (sul child)
        .sheet(isPresented: $isPresentingNewDayEditor) {
            CreateWorkoutDayView(
                workout: workoutDraft,
                onClose: {
                    isPresentingNewDayEditor = false
                }
            )
            .environment(\.managedObjectContext, childContext)
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

    // Giorni filtrati/ordinati (usa @FetchRequest reattivo)
    private var daysForUI: [WorkoutDay] {
        fetchedDays.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    // Salva immagine in Documents/Images e collega il path al draft
    private func handleImageSelected(_ image: UIImage) {
        let imageName = UUID().uuidString + ".jpg"
        if let savedPath = saveImageToDocuments(image, imageName: imageName) {
            pathToImage = savedPath
            workoutDraft.pathToImage = savedPath
        }
    }

    // Commit finale: child -> parent -> store
    private func saveAll() {
        // Valori finali dal form
        let finalName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        workoutDraft.name = finalName.isEmpty ? "New Workout" : finalName
        workoutDraft.weeks = Int16(numberWeeks) ?? 0
        workoutDraft.isSaved = true

        do {
            try childContext.save()     // child -> parent (bozza → parent)
            try parentContext.save()    // parent -> store (commit)
        } catch {
            print("❌ Errore salvataggio workout:", error)
        }
    }
}
