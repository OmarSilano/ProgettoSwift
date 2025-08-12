import SwiftUI
import CoreData

// MARK: - EDIT esistente (commit su Save)
struct EditWorkoutDayView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var day: WorkoutDay
    var onClose: () -> Void = {}
    
    // UI state
    @State private var dayName: String = ""
    @State private var details: [WorkoutDayDetail] = []
    @State private var isShowingExercisePicker = false
    @State private var typologies: [Typology] = []
    @State private var didHandleClose = false
    @State private var refreshTrigger = false

    
    // Manager
    private var detailMgr: WorkoutDayDetailManager { WorkoutDayDetailManager(context: context) }
    private var typologyMgr: TypologyManager { TypologyManager(context: context) }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                header(title: "EDIT DAY", onCancel: cancel, onSave: save)
                
                nameField
                
                detailsList
                
                addExerciseButton
                
                Spacer()
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
        }
        .onAppear {
            dayName = day.name ?? ""
            details = day.sortedDetails
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
                context.rollback()   // stesso effetto del Cancel
                onClose()
            }
        }
    }
    
    // MARK: - UI chunks (per alleggerire il compilatore)
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
                .id(refreshTrigger)
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
                                refreshTrigger.toggle()
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
    
    // MARK: - Actions
    private func addExercises(with ids: [NSManagedObjectID]) {
        let defaultTyp = (typologies.first { $0.isDefault } ?? typologies.first)!
        let existing = Set(details.compactMap { $0.exercise?.objectID })
        
        for id in ids where !existing.contains(id) {
            if let ex = try? context.existingObject(with: id) as? Exercise {
                let d = WorkoutDayDetail(context: context)
                d.id = UUID()
                d.exercise = ex
                d.typology = defaultTyp
                d.orderIndex = Int16(details.count)
                details.append(d)
            }
        }
        isShowingExercisePicker = false
    }
    
    private func deleteDetails(_ offsets: IndexSet) {
        for i in offsets {
            let det = details[i]
            if det.workoutDay == nil {
                context.delete(det)
            }
        }
        details.remove(atOffsets: offsets)
    }

    
    private func moveDetails(from source: IndexSet, to destination: Int) {
        details.move(fromOffsets: source, toOffset: destination)
        renumberOrder()
    }
    
    private func renumberOrder() {
        for (i, d) in details.enumerated() { d.orderIndex = Int16(i) }
    }
    
    private func save() {
            let trimmed = dayName.trimmingCharacters(in: .whitespacesAndNewlines)
            day.name = trimmed

            // 1) Collega al day i nuovi dettagli orfani (aggiunte)
            for det in details where det.workoutDay == nil {
                det.workoutDay = day
            }

            // 2) Cancella ORA i dettagli esistenti rimossi dalla UI
            let keptExistingIDs: Set<NSManagedObjectID> = Set(
                details.compactMap { $0.workoutDay != nil ? $0.objectID : nil }
            )
            for det in day.sortedDetails where !keptExistingIDs.contains(det.objectID) {
                context.delete(det)
            }

            // 3) Aggiorna l'ordine definitivo (su tutti quelli tenuti e nuovi)
            for (i, det) in details.enumerated() {
                det.orderIndex = Int16(i)
            }

            // 4) Calcola i muscoli SOLO ora
            day.updateMusclesFromDetails()

            do {
                try context.save()
                didHandleClose = true
                onClose()
                dismiss()
            } catch {
                print("❌ Save day error:", error)
            }
        }
    
    private func cancel() {
        didHandleClose = true
        context.rollback()
        onClose()
        dismiss()
    }
}

