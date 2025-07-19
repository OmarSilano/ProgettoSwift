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


    // Manager
    private var workoutManager: WorkoutManager {
        WorkoutManager(context: context)
    }

    private var workoutDayManager: WorkoutDayManager {
        WorkoutDayManager(context: context)
    }
    
    //salva immagine selezionata del workout in Documents/Images
    private func handleImageSelected(_ image: UIImage) {
        createImagesDirectoryIfNeeded()
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
        let id = UUID()
        let name: String
        let muscle: String
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
                            isShowingImagePicker = true
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

        }
    

    // MARK: - Save logic
    private func saveWorkout() {
        guard !workoutName.isEmpty else { return }

        let weeksValue = Int16(numberWeeks) ?? 0

        //CREATE WORKOUT
        let newWorkout = workoutManager.createWorkout(
            name: workoutName,
            weeks: weeksValue,
            pathToImage: pathToImage,
            isSaved: true)

        //CREATE WORKOUTDAY(S)
        for day in workoutDays {
                workoutDayManager.createWorkoutDay(
                    isCompleted: false,
                    name: day.name,
                    muscles: [],
                    workout: newWorkout
                )
            
        //CREATE WORKOUTDAYDETAIL(S)
        
        }

        newWorkout.days = Int16(workoutDays.count)
        dismiss()
    }
}

struct TempWorkoutDayRowView: View {
    var day: AddWorkoutView.TempWorkoutDay
    var onDelete: () -> Void
    var onEdit: () -> Void
    @Binding var expandedDayID: UUID?

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                // Delete button
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }

                // Center tappable area
                Button(action: {
                    withAnimation {
                        toggleExpansion()
                    }
                }) {
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
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())

                // Edit button
                Button(action: {
                    onEdit()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color("ThirdColor"))
            .cornerRadius(8)

            // Espansione: mostra gli esercizi
            if expandedDayID == day.id {
                if day.exercises.isEmpty {
                    Text("Nessun esercizio")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                        .padding(.bottom, 4)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(day.exercises, id: \.id) { exercise in
                            Text(exercise.name)
                                .foregroundColor(.white)
                                .font(.body)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
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

private func createImagesDirectoryIfNeeded() {
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

