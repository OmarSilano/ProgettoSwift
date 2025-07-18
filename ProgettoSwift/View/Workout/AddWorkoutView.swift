import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @State private var workoutName = "New Workout"
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var numberDays = 0
    @State private var numberWeeks = "0"
    @State private var workoutDays: [TempWorkoutDay] = []

    struct TempWorkoutDay: Identifiable {
        var id = UUID()
        var name: String
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // TextField + X button
                HStack {
                    TextField("", text: $workoutName)
                        .padding()
                        .background(Color("ThirdColor"))
                        .foregroundColor(Color("FourthColor"))
                        .cornerRadius(8)
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
                
                // Image picker
                ZStack {
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
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
                .frame(height: 200)
                .padding(.horizontal)

                // Days and Weeks
                HStack {
                    Text("\(numberDays) Days")
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("∞")
                        
                        TextField("", text: $numberWeeks)
                            .frame(width: 40, height: 40)
                            .multilineTextAlignment(.center)
                            .background(Color("ThirdColor"))
                            .foregroundColor(Color("FourthColor"))
                            .cornerRadius(8)
                            .font(.headline)
                            .keyboardType(.numberPad)
                            .onChange(of: numberWeeks) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    numberWeeks = filtered
                                }
                            }

                        
                        Text("Weeks")
                    }
                }
                .foregroundColor(Color("FourthColor"))
                .font(.headline)
                .padding(.horizontal, 30)
                
                
                // Lista Workout Days
                if !workoutDays.isEmpty {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(workoutDays) { day in
                                HStack {
                                    // Icona elimina
                                    Button(action: {
                                        if let index = workoutDays.firstIndex(where: { $0.id == day.id }) {
                                            workoutDays.remove(at: index)
                                            numberDays = workoutDays.count
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(Color("FourthColor"))
                                    }

                                    Spacer()

                                    // Testo centrato
                                    Text(day.name)
                                        .foregroundColor(Color("FourthColor"))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)

                                    Spacer()

                                    // Icona modifica
                                    Button(action: {
                                        // Azione di modifica qui
                                        print("Modifica \(day.name)")
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(Color("FourthColor"))
                                    }
                                }
                                .padding()
                                .background(Color("ThirdColor"))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 180)
                }

                
                
                // Add Day button
                Button(action: {
                    numberDays += 1
                    let newDay = TempWorkoutDay(name: "Day \(numberDays)")
                    workoutDays.append(newDay)
                    numberDays = workoutDays.count
                }) {
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

                Spacer()
            }
            .padding(.top)
            .background(Color("PrimaryColor").ignoresSafeArea())
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .navigationBarItems(
                leading: Button("Annulla") {
                    dismiss()
                }.foregroundColor(Color("FourthColor")),
                
                trailing: Button("Salva") {
                    // salva workout
                    //////////DEVO CAPIRE COME MANDARE IL PATH IMAGE
                    let newWorkout: Workout = WorkoutManager.init(context: context).createWorkout(name: workoutName, weeks: numberWeeks as Int16)
                    
                    // Crea ogni WorkoutDay associato in un REALE oggetto WorkoutDay
                        for tempDay in workoutDays {
                            workoutDayManager.createWorkoutDay(
                                isCompleted: false,
                                name: tempDay.name,
                                workout: newWorkout
                            )
                        }
                    
                }.foregroundColor(Color("FourthColor"))
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CREATE WORKOUT")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("FourthColor"))
                }
            }
        }
    }
}
