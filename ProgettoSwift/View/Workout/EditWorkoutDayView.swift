import SwiftUI
import CoreData

struct EditWorkoutDayView: View {
    @Environment(\.dismiss) var dismiss

    @State var tempDay: AddWorkoutView.TempWorkoutDay
    var onSave: (AddWorkoutView.TempWorkoutDay) -> Void

    @State private var typologies: [Typology] = []
    @State private var selectedTypologies: [UUID: Typology] = [:]
    @State private var isShowingExercisePicker = false

    private let typologyManager: TypologyManager

    init(tempDay: AddWorkoutView.TempWorkoutDay,
         onSave: @escaping (AddWorkoutView.TempWorkoutDay) -> Void,
         context: NSManagedObjectContext) {
        self._tempDay = State(initialValue: tempDay)
        self.onSave = onSave
        self.typologyManager = TypologyManager(context: context)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                
                HStack {
                    Button("Annulla") {
                        dismiss()
                    }
                    .foregroundColor(.white)

                    Spacer()

                    Text("EDIT DAY")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Salva") {
                        for index in tempDay.exercises.indices {
                            let ex = tempDay.exercises[index]
                            if let selected = selectedTypologies[ex.id] {
                                tempDay.exercises[index].typology = selected
                            }
                        }

                        onSave(tempDay)
                        dismiss()
                    }

                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Nome giorno
                TextField("Day name", text: $tempDay.name)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color("ThirdColor"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)

                // Lista esercizi
                if tempDay.exercises.isEmpty {
                    Text("No exercises yet")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(tempDay.exercises) { exercise in
                            HStack(spacing: 12) {
                                Button(action: {
                                    removeExercise(exercise)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .resizable()
                                        .frame(width: 26, height: 26)
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Circle())

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(exercise.name)
                                            .foregroundColor(.white)
                                            .font(.headline)

                                        Spacer()

                                        Menu {
                                            ForEach(typologies, id: \.self) { typ in
                                                Button(action: {
                                                    selectedTypologies[exercise.id] = typ
                                                }) {
                                                    Text(typ.name ?? "")
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text(selectedTypologies[exercise.id]?.name ?? typologies.first?.name ?? "")
                                                    .foregroundColor(Color("SubtitleColor"))
                                                    .font(.subheadline)

                                                Image(systemName: "chevron.down")
                                                    .resizable()
                                                    .frame(width: 10, height: 6)
                                                    .foregroundColor(Color("SubtitleColor"))
                                                    .padding(.top, 2)
                                            }
                                        }
                                    }
                                }

                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                            .listRowBackground(Color("ThirdColor"))
                        }




                        .onMove(perform: moveExercise)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color("PrimaryColor"))
                }

                // Bottone add exercise
                Button {
                    isShowingExercisePicker = true
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
            .onAppear {
                typologies = typologyManager.fetchAllTypologies()

                for ex in tempDay.exercises {
                    if let typ = ex.typology {
                        selectedTypologies[ex.id] = typ
                    }
                }
            }

            .sheet(isPresented: $isShowingExercisePicker) {
                ExercisePickerView(
                    onSelect: { newExercises in
                        if let defaultTypology = typologies.first(where: { $0.name == "4x10" }) {
                            let previewsWithTypology = newExercises.map { exercise in
                                selectedTypologies[exercise.id] = defaultTypology

                                return AddWorkoutView.ExercisePreview(
                                    id: exercise.id,
                                    name: exercise.name,
                                    muscle: exercise.muscle,
                                    typology: defaultTypology
                                )
                            }

                            tempDay.exercises.append(contentsOf: previewsWithTypology)
                        } else {
                            tempDay.exercises.append(contentsOf: newExercises)
                        }
                    }
                )
            }


        }
    }

    private func removeExercise(_ exercise: AddWorkoutView.ExercisePreview) {
        tempDay.exercises.removeAll { $0.id == exercise.id }
    }

    private func moveExercise(from source: IndexSet, to destination: Int) {
        tempDay.exercises.move(fromOffsets: source, toOffset: destination)
    }
}

