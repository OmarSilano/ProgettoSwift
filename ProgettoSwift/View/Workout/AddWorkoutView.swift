import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss

    @State private var workoutName = "New Workout"
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberWeeks = ""
    @State private var workoutDays: [TempWorkoutDay] = []
    @State private var expandedDayID: UUID? = nil
    @State private var dayBeingEdited: TempWorkoutDay? = nil
    @State private var pathToImage: String? = nil
    @State private var showPermissionAlert = false



    // Manager
    private var workoutManager: WorkoutManager {
        WorkoutManager(context: context)
    }

    private var workoutDayManager: WorkoutDayManager {
        WorkoutDayManager(context: context)
    }
    
    //salva immagine selezionata del workout in Documents/Images
    private func handleImageSelected(_ image: UIImage) {

        let imageName = UUID().uuidString + ".jpg"  // univoco
        if let savedPath = saveImageToDocuments(image, imageName: imageName) {
            print("Immagine salvata in: \(savedPath)")
            pathToImage = savedPath
        }
    }

    struct TempWorkoutDay: Identifiable {
        var id = UUID()
        var name: String
        var exercises: [ExercisePreview] = []

        var muscleGroupsText: String {
            let uniqueMuscles = Set(exercises.map { $0.muscle })
            let limited = Array(uniqueMuscles).prefix(2)
            var text = limited.joined(separator: " • ")
            if uniqueMuscles.count > 2 {
                text += " ..."
            }
            return text
        }
    }

    struct ExercisePreview: Identifiable {
        let id: UUID
        let name: String
        let muscle: String
        var typology: Typology?
    }



    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Top bar
                    HStack {
                        Button {
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
                            saveWorkout()
                        }
                        .foregroundColor(Color("FourthColor"))
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // TextField WorkoutName+ X button
                    HStack {
                        TextField("",text: $workoutName)
                            .foregroundColor(Color("FourthColor"))
                            .font(.headline)

                        if !workoutName.isEmpty {
                            Button(action: {
                                workoutName = ""
                            }) {
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

                    // Weeks input + Days count
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

                    // Workout days list
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

                    // Add day button
                    Button {
                        let newDay = TempWorkoutDay(
                            name: "\(workoutDays.count + 1)° Day",
                            exercises: [] // oppure mock temporaneo per test
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
            .onChange(of: selectedImage) { newImage in
                if let img = newImage {
                    handleImageSelected(img)
                }
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
    

    // MARK: - Save logic
    private func saveWorkout() {
        guard !workoutName.isEmpty else { return }

        let weeksValue = Int16(numberWeeks) ?? 0

        let newWorkout = workoutManager.createWorkout(
            name: workoutName,
            weeks: weeksValue,
            pathToImage: pathToImage,
            isSaved: true
        )

        let exerciseManager = ExerciseManager(context: context)
        let workoutDayDetailManager = WorkoutDayDetailManager(context: context)

        var totalDays = 0

        for day in workoutDays {
            let newDay = workoutDayManager.createWorkoutDay(
                isCompleted: false,
                name: day.name,
                muscles: [],
                workout: newWorkout
            )

            totalDays += 1
            for exercisePreview in day.exercises {
                guard let originalExercise = exerciseManager.fetchExercise(byID: exercisePreview.id),
                      let typology = exercisePreview.typology else {
                    print("⚠️ Esercizio o tipologia mancanti per \(exercisePreview.name)")
                    continue
                }

                _ = workoutDayDetailManager.createWorkoutDayDetail(
                    workoutDay: newDay,
                    exercise: originalExercise,
                    typology: typology
                )
            }
            newDay.updateMusclesFromDetails()
        }
        newWorkout.days = Int16(totalDays)
        dismiss()
    }
}

struct TempWorkoutDayRowView: View {
    var day: AddWorkoutView.TempWorkoutDay
    var onDelete: () -> Void
    var onEdit: () -> Void
    @Binding var expandedDayID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Delete button
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())


                // Area centrale tappabile
                VStack(spacing: 2) {
                    Text(day.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    if !day.muscleGroupsText.isEmpty {
                        Text(day.muscleGroupsText)
                            .font(.subheadline)
                            .foregroundColor(Color("SubtitleColor"))
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle()) // Rende tappabile tutta l'area del VStack
                .onTapGesture {
                    withAnimation {
                        toggleExpansion()
                    }
                }

                // Edit button
                Button(action: {
                    onEdit()
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())

            }
            .padding()
            .background(Color("ThirdColor"))

            // Espansione: mostra gli esercizi
            if expandedDayID == day.id {
                if day.exercises.isEmpty {
                    Text("No exercises yet...")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                        .padding(.bottom, 4)
                } else {
                    if expandedDayID == day.id {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(day.exercises, id: \.id) { exercise in
                                WorkoutExercisePreviewRowView(preview: exercise)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color("ThirdColor"))
                        .transition(.opacity)
                    }
                }
            }

            Divider().background(Color("ThirdColor").opacity(0.3))
        }
        .padding(.horizontal)
    }

    private func toggleExpansion() {
        expandedDayID = (expandedDayID == day.id) ? nil : day.id
    }
}

struct WorkoutExercisePreviewRowView: View {
    let preview: AddWorkoutView.ExercisePreview

    var body: some View {
        HStack(spacing: 12) {
            // Immagine (se disponibile)
            if let path = previewImagePath(), let image = UIImage(named: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(preview.name)
                    .foregroundColor(.white)
                    .font(.subheadline)

                Text(preview.typology?.name ?? "Method")
                    .foregroundColor(Color("SubtitleColor"))
                    .font(.caption)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func previewImagePath() -> String? {
        // Ritorna solo il nome del file, non il percorso completo
        if let last = preview.typology?.name, !last.isEmpty {
            return last
        }
        return preview.name // oppure nil
    }
}


/* SPOSTATE IN IMAGEUTILS
func createImagesDirectoryIfNeeded() {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imagesURL = documentsURL.appendingPathComponent("images")

    if !fileManager.fileExists(atPath: imagesURL.path) {
        do {
            try fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: true, attributes: nil)
            print("Cartella images creata")
        } catch {
            print("Errore creando la cartella images: \(error)")
        }
    }
}


func saveImageToDocuments(_ image: UIImage, imageName: String) -> String? {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let imagesURL = documentsURL.appendingPathComponent("images")
    let fileURL = imagesURL.appendingPathComponent(imageName)

    guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

    do {
        try data.write(to: fileURL)
        return fileURL.path // questo è il percorso assoluto da salvare
    } catch {
        print("Errore salvando l'immagine: \(error)")
        return nil
    }
}

*/
