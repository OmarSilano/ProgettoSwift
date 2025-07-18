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
                // Nome giorno
                TextField("Day name", text: $tempDay.name)
                    .padding()
                    .background(Color("ThirdColor"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)

                // Lista esercizi
                if tempDay.exercises.isEmpty {
                    Text("No exercises yet")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(tempDay.exercises) { exercise in
                            HStack {
                                // Delete
                                Button(action: {
                                    removeExercise(exercise)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }

                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .foregroundColor(.white)
                                    Picker("Typology", selection: Binding(
                                        get: {
                                            selectedTypologies[exercise.id] ?? typologies.first!
                                        },
                                        set: { newValue in
                                            selectedTypologies[exercise.id] = newValue
                                        }
                                    )) {
                                        ForEach(typologies, id: \.self) { typ in
                                            Text(typ.name ?? "").tag(typ)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }

                                Spacer()

                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.gray)
                            }
                        }
                        .onMove(perform: moveExercise)
                    }
                    .listStyle(PlainListStyle())
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
            .navigationTitle("Edit Day")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button("Annulla") {
                        dismiss()
                    }.foregroundColor(.white),
                trailing:
                    Button("Salva") {
                        onSave(tempDay)
                        dismiss()
                    }.foregroundColor(.green)
            )
            .onAppear {
                typologies = typologyManager.fetchAllTypologies()
            }
            .sheet(isPresented: $isShowingExercisePicker) {
                ExercisePickerView(
                    onSelect: { newExercises in
                        tempDay.exercises.append(contentsOf: newExercises)
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

