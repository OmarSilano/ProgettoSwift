import SwiftUI
import CoreData

// MARK: - CREATE nuovo giorno (commit su Save)
struct CreateWorkoutDayView: View {
    @Environment(\.managedObjectContext) private var envContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var workout: Workout
    var presetName: String? = nil
    var onClose: () -> Void = {}
    
    private var ctx: NSManagedObjectContext { workout.managedObjectContext ?? envContext }
    
    // UI state
    @State private var dayName: String = ""
    @State private var day: WorkoutDay? = nil
    @State private var details: [WorkoutDayDetail] = []
    @State private var isShowingExercisePicker = false
    @State private var typologies: [Typology] = []
    @State private var didHandleClose = false
    
    
    private var dayMgr: WorkoutDayManager { WorkoutDayManager(context: ctx) }
    private var detailMgr: WorkoutDayDetailManager { WorkoutDayDetailManager(context: ctx) }
    private var typologyMgr: TypologyManager { TypologyManager(context: ctx) }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                header(title: "NEW DAY", onCancel: cancel, onSave: save)
                
                nameField
                
                detailsList
                
                addExerciseButton
                
                Spacer()
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
        }
        .onAppear {
            let suggested = presetName ?? "Day \(((workout.workoutDay as? Set<WorkoutDay>)?.count ?? 0) + 1)"
            
            let newDay = WorkoutDay(context: ctx)
            newDay.id = UUID()
            newDay.name = suggested
            newDay.isCompleted = false
            
            day = newDay
            dayName = suggested
            typologies = typologyMgr.fetchAllTypologies()
        }
        .sheet(isPresented: $isShowingExercisePicker) {
            ExercisePickerView(
                onSelect: { ids in addExercises(with: ids) },
                preselectedIDs: Set(details.compactMap { $0.exercise?.objectID })
            )
        }
        .onDisappear {
            if !didHandleClose {
                ctx.rollback()   // stesso effetto del Cancel
                onClose()
            }
        }
    }
    
    // UI chunks (riuso quelli sopra)
    private func header(title: String, onCancel: @escaping () -> Void, onSave: @escaping () -> Void) -> some View {
        HStack {
            Button("Cancel", action: onCancel).foregroundColor(.white)
            Spacer()
            Text(title).font(.system(size: 22, weight: .bold)).foregroundColor(.white)
            Spacer()
            Button("Save", action: onSave).foregroundColor(.white)
        }
        .padding(.horizontal, 16).padding(.top, 12)
    }
    
    private var nameField: some View {
        TextField("Day name", text: $dayName)
            .padding(.vertical, 12).padding(.horizontal, 16)
            .background(Color("ThirdColor"))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal, 16)
    }
    
    private var detailsList: some View {
        Group {
            if details.isEmpty {
                Text("No exercises yet").foregroundColor(.gray)
            } else {
                List {
                    ForEach(details, id: \.objectID) { d in
                        detailRow(detail: d)
                    }
                    .onMove(perform: moveDetails)
                }
                .environment(\.editMode, .constant(.active))
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color("PrimaryColor"))
            }
        }
    }
    
    private func detailRow(detail d: WorkoutDayDetail) -> some View {
        HStack(spacing: 12) {
            Button {
                if let idx = details.firstIndex(where: { $0.objectID == d.objectID }) {
                    deleteDetails(IndexSet(integer: idx))
                }
            } label: {
                Image(systemName: "minus.circle").resizable().frame(width: 26, height: 26).foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(d.exercise?.name ?? "Exercise")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(typologies, id: \.objectID) { t in
                            Button(t.name ?? "Typology") {
                                d.typology = t
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(d.typology?.name ?? "Method")
                                .foregroundColor(Color("SubtitleColor"))
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .resizable().frame(width: 10, height: 6)
                                .foregroundColor(Color("SubtitleColor"))
                                .padding(.top, 2)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .listRowBackground(Color("ThirdColor"))
    }
    
    private var addExerciseButton: some View {
        Button {
            isShowingExercisePicker = true
        } label: {
            HStack { Image(systemName: "plus"); Text("Add Exercise") }
                .foregroundColor(.black)
                .padding()
                .background(Color.green)
                .cornerRadius(20)
        }
        .padding()
    }
    
    // Actions
    private func addExercises(with ids: [NSManagedObjectID]) {
        guard let day else { return }
        let defaultTyp = (typologies.first { $0.isDefault } ?? typologies.first)!
        
        let existing = Set(details.compactMap { $0.exercise?.objectID })
        for id in ids where !existing.contains(id) {
            if let ex = try? ctx.existingObject(with: id) as? Exercise {
                let d = detailMgr.createTempWorkoutDayDetail(
                    workoutDay: day,
                    exercise: ex,
                    typology: defaultTyp,
                    orderIndex: Int16(details.count)
                )
                details.append(d)
            }
        }
        isShowingExercisePicker = false
    }
    
    private func deleteDetails(_ offsets: IndexSet) {
        for i in offsets { ctx.delete(details[i]) }
        details.remove(atOffsets: offsets)
        renumberOrder()
    }
    
    private func moveDetails(from source: IndexSet, to destination: Int) {
        details.move(fromOffsets: source, toOffset: destination)
        renumberOrder()
    }
    
    private func renumberOrder() {
        for (i, d) in details.enumerated() { d.orderIndex = Int16(i) }
    }
    
    private func save() {
        guard let day else { return }
        
        let trimmed = dayName.trimmingCharacters(in: .whitespacesAndNewlines)
        day.name = trimmed
        
        // 🔒 anti-crash: stesso context
        guard day.managedObjectContext === workout.managedObjectContext else {
            print("⚠️ Context mismatch: skip link to avoid crash")
            return
        }
        
        day.workout = workout
        day.updateMusclesFromDetails()
        
        do {
            didHandleClose = true
            try ctx.save()
            onClose()
            dismiss()
        } catch {
            print("❌ Save new day error:", error)
        }
    }
    
    private func cancel() {
        didHandleClose = true
        ctx.rollback()
        onClose()
        dismiss()
    }
}

