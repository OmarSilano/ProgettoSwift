import SwiftUI
import CoreData

struct EditWorkoutView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var workout: Workout
    
    // UI state
    @State private var workoutName: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberWeeks: String = ""
    @State private var expandedDayID: NSManagedObjectID? = nil
    
    // Editor Day (sheet con Bool + selezione)
    @State private var isEditingDay = false
    @State private var selectedDay: WorkoutDay? = nil
    
    @State private var pathToImage: String? = nil
    @State private var persistedImage: UIImage? = nil
    @State private var showPermissionAlert = false
    
    @State private var stagedDeletedDayIDs = Set<NSManagedObjectID>()
    @State private var isPresentingNewDayEditor = false
    
    private let maxDays = 7
    @State private var showMaxDaysAlert = false
    @State private var nextDayNameForCreate: String? = nil
    private var canAddDay: Bool { daysForUI.count < maxDays }
    
    // Manager
    private var workoutManager: WorkoutManager { WorkoutManager(context: context) }
    private var workoutDayManager: WorkoutDayManager { WorkoutDayManager(context: context) }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerBar
                nameField
                workoutImageSection
                weeksCounterRow
                Divider().background(Color("ThirdColor"))
                daysList
                addDayButton
                Spacer(minLength: 50)
            }
            .padding(.top)
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        // EDIT Day esistente
        .sheet(
            isPresented: Binding(
                get: { isEditingDay && selectedDay != nil },
                set: { newValue in
                    if !newValue {
                        isEditingDay = false
                        selectedDay = nil
                    } else {
                        isEditingDay = true
                    }
                }
            )
        ) {
            // a questo punto selectedDay è sicuramente non-nil
            EditWorkoutDayView(
                day: selectedDay!,
                onClose: {
                    isEditingDay = false
                    selectedDay = nil
                }
            )
        }
        // ADD Day (creazione nell’editor)
        .sheet(isPresented: $isPresentingNewDayEditor) {
            CreateWorkoutDayView(
                workout: workout,
                presetName: nextDayNameForCreate,
                onClose: {
                    isPresentingNewDayEditor = false
                    nextDayNameForCreate = nil
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
        .alert("Limit reached", isPresented: $showMaxDaysAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can create up to 7 training days per workout.")
        }
        .onAppear {
            initializeFromWorkout()
            refreshPersistedImage()
        }
        .onChange(of: selectedImage) { (img: UIImage?) in
            if let image = img { handleImageSelected(image) }
        }
        .onChange(of: pathToImage) { (_: String?) in
            refreshPersistedImage()
        }
    }
    
    // MARK: - Extracted sections
    
    private var headerBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            Spacer()
            
            Text("EDIT WORKOUT")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Save") {
                saveWorkoutChanges()
            }
            .foregroundColor(Color("FourthColor"))
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var nameField: some View {
        HStack {
            TextField("Insert Workout Name", text: $workoutName)
                .foregroundColor(Color("FourthColor"))
                .font(.headline)
            
            if !workoutName.isEmpty {
                Button(action: { workoutName = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color("SecondaryColor"))
                }
            }
        }
        .padding(.horizontal)
        .padding()
        .background(Color("ThirdColor"))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var workoutImageSection: some View {
        ZStack {
            if let image = selectedImage ?? persistedImage {
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
    }
    
    private var weeksCounterRow: some View {
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
                    .onChange(of: numberWeeks) { (newValue: String) in
                        numberWeeks = newValue.filter { "0123456789".contains($0) }
                    }
                
                Text("Weeks")
                    .foregroundColor(Color("FourthColor"))
                    .font(.headline)
            }
        }
        .padding(.horizontal, 30)
    }
    
    private var daysList: some View {
        let days: [WorkoutDay] = daysForUI
        return Group {
            if !days.isEmpty {
                VStack(spacing: 10) {
                    ForEach(days, id: \.objectID) { (day: WorkoutDay) in
                        WorkoutDayRow_CoreData(
                            day: day,
                            expandedDayID: $expandedDayID,
                            onDelete: {
                                stagedDeletedDayIDs.insert(day.objectID)
                                if expandedDayID == day.objectID { expandedDayID = nil }
                            },
                            onEdit: {
                                // se era stato marcato per delete, lo riabilito
                                stagedDeletedDayIDs.remove(day.objectID)
                                selectedDay = day
                                isEditingDay = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var addDayButton: some View {
        Button {
            guard canAddDay else {
                showMaxDaysAlert = true
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                return
            }
            nextDayNameForCreate = "Day \(daysForUI.count + 1)"  // <- n+1, basato su giorni visibili
            isPresentingNewDayEditor = true
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
    }
    
    // MARK: - Helpers
    
    private var daysForUI: [WorkoutDay] {
        let set = (workout.workoutDay as? Set<WorkoutDay>) ?? []
        return set
            .filter { !stagedDeletedDayIDs.contains($0.objectID) }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    private func initializeFromWorkout() {
        workoutName = workout.name ?? ""
        numberWeeks = "\(workout.weeks)"
        pathToImage = workout.pathToImage
    }
    
    private func refreshPersistedImage() {
        guard let path = pathToImage, !path.isEmpty else {
            persistedImage = nil
            return
        }
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let img = UIImage(data: data) {
            persistedImage = img
        } else {
            persistedImage = nil
        }
    }
    
    // Save finale: applica nome/settimane/immagine + esegue davvero le delete
    private func saveWorkoutChanges() {
        let trimmed = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 1) Cancella i giorni marcati (manager salva)
        for id in stagedDeletedDayIDs {
            if let day = try? context.existingObject(with: id) as? WorkoutDay {
                workoutDayManager.deleteWorkoutDay(day)
            }
        }
        
        // 2) Ricalcola il conteggio dei giorni rimasti
        let remaining = ((workout.workoutDay as? Set<WorkoutDay>) ?? []).count
        workout.days = Int16(remaining)
        
        // 3) Aggiorna i campi del workout (manager salva)
        workoutManager.updateWorkout(
            workout,
            name: trimmed,
            weeks: Int16(numberWeeks) ?? workout.weeks,
            pathToImage: pathToImage
        )
        
        dismiss()
    }
    
    // Salvataggio locale dell’immagine (non scrive sul workout finché non premi Save)
    private func handleImageSelected(_ image: UIImage) {
        let imageName = UUID().uuidString + ".jpg"
        if let savedPath = saveImageToDocuments(image, imageName: imageName) {
            pathToImage = savedPath
        }
    }
}
