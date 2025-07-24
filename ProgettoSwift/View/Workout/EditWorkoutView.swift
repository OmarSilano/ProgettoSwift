import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss

    let workout: Workout

    @State private var workoutName: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberWeeks: String = ""
    @State private var workoutDays: [AddWorkoutView.TempWorkoutDay] = []
    @State private var expandedDayID: UUID? = nil
    @State private var dayBeingEdited: AddWorkoutView.TempWorkoutDay? = nil
    @State private var pathToImage: String? = nil
    @State private var showPermissionAlert = false


    private var workoutDayManager: WorkoutDayManager {
        WorkoutDayManager(context: context)
    }

    private var workoutDayDetailManager: WorkoutDayDetailManager {
        WorkoutDayDetailManager(context: context)
    }

    private var exerciseManager: ExerciseManager {
        ExerciseManager(context: context)
    }

    // MARK: - View
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

                    Text("EDIT WORKOUT")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(Color("FourthColor"))
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // TextField WorkoutName
                HStack {
                    TextField("", text: $workoutName)
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

                // Image picker
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else if let path = workout.pathToImage,
                              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                              let image = UIImage(data: data) {
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

                    Button(action: {
                        Task {
                            //chiedo il permesso per la galleria se non ce l'ho
                            let granted = await Permissions().requestGalleryPermission()
                            if granted {
                                isShowingImagePicker = true
                            } else {
                                showPermissionAlert = true
                            }
                        }
                    }) {
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

                // Weeks + Day counter
                HStack {
                    Text("\(workoutDays.count) Days")
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
                if !workoutDays.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(workoutDays) { day in
                            TempWorkoutDayRowView(
                                day: day,
                                onDelete: {
                                    workoutDays.removeAll { $0.id == day.id }
                                },
                                onEdit: {
                                    dayBeingEdited = day
                                },
                                expandedDayID: $expandedDayID
                            )
                        }
                    }
                }

                // Bottone aggiunta giorno
                Button {
                    let newDay = AddWorkoutView.TempWorkoutDay(
                        name: "\(workoutDays.count + 1)° Day",
                        exercises: []
                    )
                    workoutDays.append(newDay)
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
        .sheet(item: $dayBeingEdited) { day in
            EditWorkoutDayView(
                tempDay: day,
                onSave: { updatedDay in
                    if let index = workoutDays.firstIndex(where: { $0.id == updatedDay.id }) {
                        workoutDays[index] = updatedDay
                    }
                    dayBeingEdited = nil
                },
                context: context
            )
        }
        .onChange(of: selectedImage) { newImage in
            if let img = newImage {
                handleImageSelected(img)
            }
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

        .onAppear {
            initializeFromWorkout()
        }
    }

    // MARK: - Setup iniziale
    private func initializeFromWorkout() {
        workoutName = workout.name ?? ""
        numberWeeks = "\(workout.weeks)"
        pathToImage = workout.pathToImage

        if let days = workout.workoutDay?.allObjects as? [WorkoutDay] {
            let sortedDays = days.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
            
            workoutDays = sortedDays.map { day in
                AddWorkoutView.TempWorkoutDay(
                    id: day.id ?? UUID(),
                    name: day.name ?? "Unnamed",
                    exercises: (day.workoutDayDetail?.allObjects as? [WorkoutDayDetail])?.compactMap {
                        guard let ex = $0.exercise,
                              let id = ex.id,
                              let name = ex.name,
                              let muscle = ex.muscle else { return nil }

                        return AddWorkoutView.ExercisePreview(
                            id: id,
                            name: name,
                            muscle: muscle,
                            typology: $0.typology
                        )
                    } ?? []
                )
            }
        }

    }

    // MARK: - Salvataggio modifiche
    private func saveChanges() {
        guard !workoutName.isEmpty else { return }
        workout.name = workoutName
        workout.weeks = Int16(numberWeeks) ?? 0
        workout.pathToImage = pathToImage

        // Rimuovi giorni e dettagli esistenti
        if let existingDays = workout.workoutDay as? Set<WorkoutDay> {
            for day in existingDays {
                if let details = day.workoutDayDetail as? Set<WorkoutDayDetail> {
                    details.forEach(context.delete)
                }
                context.delete(day)
            }
        }

        // Ricrea i nuovi
        var totalDays: Int = 0
        for day in workoutDays {
            let newDay = workoutDayManager.createWorkoutDay(
                isCompleted: false,
                name: day.name,
                muscles: [],
                workout: workout
            )
            totalDays += 1

            for exercisePreview in day.exercises {
                guard let ex = exerciseManager.fetchExercise(byID: exercisePreview.id),
                      let typology = exercisePreview.typology else {
                    continue
                }

                _ = workoutDayDetailManager.createWorkoutDayDetail(
                    workoutDay: newDay,
                    exercise: ex,
                    typology: typology
                )
            }

            newDay.updateMusclesFromDetails()
        }

        workout.days = Int16(totalDays)
        dismiss()
    }

    private func handleImageSelected(_ image: UIImage) {
        createImagesDirectoryIfNeeded()
        let imageName = UUID().uuidString + ".jpg"
        if let savedPath = saveImageToDocuments(image, imageName: imageName) {
            print("Immagine aggiornata in: \(savedPath)")
            pathToImage = savedPath
        }
    }
}
