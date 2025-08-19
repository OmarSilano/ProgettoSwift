import SwiftUI
import CoreData

struct AddWorkoutHost: View {
    private let parentContext: NSManagedObjectContext
    private let childContext: NSManagedObjectContext
    
    @StateObject private var draft: Workout
    
    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        
        let child = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        child.parent = parentContext
        child.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        child.automaticallyMergesChangesFromParent = false
        self.childContext = child
        
        // Crea il draft NEL CHILD
        let w = Workout(context: child,
                        name: "New Workout",
                        weeks: 0,
                        imagePath: nil,
                        difficulty: .beginner,
                        category: nil,
                        isSaved: false)
        _draft = StateObject(wrappedValue: w)
    }
    
    var body: some View {
        // la AddWorkoutView legge il child dall’ambiente
        AddWorkoutView(parentContext: parentContext, workoutDraft: draft)
            .environment(\.managedObjectContext, childContext)
    }
}


struct AddWorkoutView: View {
    // Context
    let parentContext: NSManagedObjectContext
    @Environment(\.managedObjectContext) private var childContext
    @ObservedObject var workoutDraft: Workout
    
    @Environment(\.dismiss) private var dismiss
    
    // UI state
    @State private var workoutName = "New Workout"
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberWeeks = ""
    @State private var expandedDayID: NSManagedObjectID? = nil
    @State private var editingDay: WorkoutDay? = nil
    @State private var pathToImage: String? = nil
    @State private var showPermissionAlert = false
    @State private var isPresentingNewDayEditor = false
    @State private var refreshTrigger = false

    private let maxDays = 7
    @State private var showMaxDaysAlert = false
    private var canAddDay: Bool { fetchedDays.count < maxDays }
    
    // Fetch dei Day
    @FetchRequest private var fetchedDays: FetchedResults<WorkoutDay>
    
    init(parentContext: NSManagedObjectContext, workoutDraft: Workout) {
        self.parentContext = parentContext
        self.workoutDraft = workoutDraft
        _fetchedDays = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutDay.name, ascending: true)],
            predicate: NSPredicate(format: "workout == %@", workoutDraft)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button {
                        cancel()
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
                            if granted { isShowingImagePicker = true } else { showPermissionAlert = true }
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
                    Text("\(fetchedDays.count) Days")
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
                
                // Lista giorni (reattiva sul CHILD)
                if !fetchedDays.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(fetchedDays, id: \.objectID) { day in
                            WorkoutDayRow_CoreData(
                                day: day,
                                expandedDayID: $expandedDayID,
                                onDelete: {
                                    childContext.delete(day) // elimina dal child
                                    refreshTrigger.toggle()
                                },
                                onEdit: {
                                    editingDay = day
                                }
                            )
                        }
                    }
                    .id(refreshTrigger)
                    .padding(.horizontal)
                }
                
                Button {
                    guard canAddDay else {
                        showMaxDaysAlert = true
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        return
                    }
                    
                    ensurePermanentID(workoutDraft, in: childContext)
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
        
        // Picker immagine
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { img in
            if let image = img { handleImageSelected(image) }
        }
        
        // EDIT Day (eredita il child dall’ambiente)
        .sheet(item: $editingDay) { day in
            EditWorkoutDayView(
                day: day,
                onClose: {
                    editingDay = nil
                    refreshTrigger.toggle()
                }
            )
            .environment(\.managedObjectContext, childContext)
            .id(day.objectID) // forza un rebuild del contenuto alla prima apertura
        }
        
        // CREATE Day (eredita il child dall’ambiente)
        .sheet(isPresented: $isPresentingNewDayEditor) {
            CreateWorkoutDayView(
                workout: workoutDraft,
                onClose: {
                    isPresentingNewDayEditor = false
                    refreshTrigger.toggle()
                }
            )
        }
        .alert("Limit reached", isPresented: $showMaxDaysAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can create up to 7 training days per workout.")
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
    
    private func ensurePermanentID(_ obj: NSManagedObject, in ctx: NSManagedObjectContext) {
        guard obj.objectID.isTemporaryID else { return }
        do { try ctx.obtainPermanentIDs(for: [obj]) }
        catch { print("⚠️ obtainPermanentIDs:", error) }
    }
        
    // MARK: - Azioni
    
    private func cancel() {
        let draftID = workoutDraft.objectID
        
        // 1) Pulisci il CHILD
        childContext.performAndWait {
            if workoutDraft.isInserted || workoutDraft.hasChanges {
                childContext.delete(workoutDraft)
            }
            childContext.rollback()
            childContext.reset()
        }
        
        // 2) Pulisci il PARENT
        parentContext.performAndWait {
            if let parentDraft = try? parentContext.existingObject(with: draftID) as? Workout, !parentDraft.isFault {
                parentContext.delete(parentDraft)
            }
            parentContext.rollback()
            parentContext.processPendingChanges()
        }
    }
    
    // Salva immagine in Documents/Images e collega il path al draft
    private func handleImageSelected(_ image: UIImage) {
        let imageName = UUID().uuidString + ".jpg"
        if let savedPath = saveImageToDocuments(image, imageName: imageName) {
            pathToImage = savedPath
            workoutDraft.pathToImage = savedPath
        }
    }
    
    
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

