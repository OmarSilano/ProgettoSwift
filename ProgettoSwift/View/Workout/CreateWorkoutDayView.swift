import SwiftUI
import CoreData

// MARK: - CREATE nuovo giorno (commit su Save)
struct CreateWorkoutDayView: View {
    @Environment(\.managedObjectContext) private var envContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var workout: Workout
    var presetName: String? = nil
    var onClose: () -> Void = {}
    
    @State private var lockedCtx: NSManagedObjectContext? = nil
    private var ctx: NSManagedObjectContext {
        lockedCtx ?? workout.managedObjectContext ?? envContext
    }
    
    // UI state
    @State private var dayName: String = ""
    @State private var day: WorkoutDay? = nil
    @State private var details: [WorkoutDayDetail] = []
    @State private var isShowingExercisePicker = false
    @State private var typologies: [Typology] = []
    @State private var didHandleClose = false
    @State private var refreshTrigger = false

    
    
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
            if lockedCtx == nil {
                lockedCtx = workout.managedObjectContext ?? envContext
                print("🟢 lockedCtx =", ctxID(lockedCtx))
            }
            
            let suggested = presetName ?? "Day \(((workout.workoutDay as? Set<WorkoutDay>)?.count ?? 0) + 1)"
            
            let newDay = WorkoutDay(context: ctx)
            newDay.id = UUID()
            newDay.name = suggested
            newDay.isCompleted = false
            
            day = newDay
            dayName = suggested
            print("🆕 Created day =", objDesc(newDay), "in", ctxID(newDay.managedObjectContext))
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
    
    private func cancel() {
        didHandleClose = true
        ctx.rollback()
        onClose()
        dismiss()
    }
    
    
    
    private func save() {
        guard let rawDay = day else { return }

        let trimmed = dayName.trimmingCharacters(in: .whitespacesAndNewlines)
        rawDay.name = trimmed
        rawDay.updateMusclesFromDetails()

        // Log pre-link
        print("💾 SAVE DAY start")
        print("   ctx =", ctxID(ctx))
        print("   day =", objDesc(rawDay), "in", ctxID(rawDay.managedObjectContext))
        print("   workout =", objDesc(workout), "in", ctxID(workout.managedObjectContext))

        do {
            // Prova a risolvere e linkare nel context target
            let (resolvedDay, resolvedWorkout) = try linkInSameContext(day: rawDay, workout: workout)

            // Verifica finale: se (ancora) mismatch, non linkare per evitare crash
            guard resolvedDay.managedObjectContext === resolvedWorkout.managedObjectContext else {
                print("⚠️ Context mismatch: skip link to avoid crash")
                return
            }

            didHandleClose = true
            try ctx.save()
            print("✅ SAVE DAY ok in", ctxID(ctx))
            onClose()
            dismiss()
        } catch {
            print("❌ Save new day error:", error)
        }
    }

    
    // Helpers (con print di debug)
    private func ensurePermanentIDs(_ objects: [NSManagedObject]) {
        // gruppa per context e converte solo i temp ID
        let ctxs = Dictionary(grouping: objects.compactMap { $0 }) { $0.managedObjectContext }
        for (maybeCtx, objs) in ctxs {
            guard let c = maybeCtx else { continue }
            let temps = objs.filter { $0.objectID.isTemporaryID }
            if !temps.isEmpty {
                print("🔧 obtainPermanentIDs in \(ctxID(c)) ->", temps.map { objDesc($0) })
                do { try c.obtainPermanentIDs(for: temps) }
                catch { print("❌ obtainPermanentIDs failed:", error) }
            }
        }
    }

    
    private func linkInSameContext(day: WorkoutDay, workout: Workout) throws -> (WorkoutDay, Workout) {
        let target = ctx // context “bloccato” dallo sheet
        print("🔗 linkInSameContext target =", ctxID(target))
        print("   day    =", objDesc(day), "in", ctxID(day.managedObjectContext))
        print("   workout=", objDesc(workout), "in", ctxID(workout.managedObjectContext))

        // 1) Assicurati che gli ID siano permanenti
        ensurePermanentIDs([day, workout])

        // 2) (Ri)materializza nel target
        let dayInTarget: WorkoutDay = {
            if day.managedObjectContext === target { return day }
            return (try? target.existingObject(with: day.objectID) as? WorkoutDay) ?? day
        }()

        let workoutInTarget: Workout = {
            if workout.managedObjectContext === target { return workout }
            return (try? target.existingObject(with: workout.objectID) as? Workout) ?? workout
        }()

        print("   -> resolved day   =", objDesc(dayInTarget), "in", ctxID(dayInTarget.managedObjectContext))
        print("   -> resolved workout=", objDesc(workoutInTarget), "in", ctxID(workoutInTarget.managedObjectContext))

        // 3) Link
        if dayInTarget.managedObjectContext !== workoutInTarget.managedObjectContext {
            // non dovremmo arrivarci, ma logghiamo in chiaro
            print("⚠️ Context mismatch after resolve:",
                  ctxID(dayInTarget.managedObjectContext), "vs", ctxID(workoutInTarget.managedObjectContext))
        } else {
            dayInTarget.workout = workoutInTarget
            print("✅ Linked day.workout in", ctxID(dayInTarget.managedObjectContext))
        }

        return (dayInTarget, workoutInTarget)
    }

    
    
    // MARK: - Debug helpers---------------------------------------------------------------------
    private func ctxID(_ ctx: NSManagedObjectContext?) -> String {
        guard let c = ctx else { return "nil" }
        let ptr = Unmanaged.passUnretained(c).toOpaque()
        let type = (c.concurrencyType == .mainQueueConcurrencyType) ? "main" :
                   (c.concurrencyType == .privateQueueConcurrencyType) ? "private" : "confined"
        return "CTX[\(type) \(ptr)]"
    }

    private func objDesc(_ obj: NSManagedObject?) -> String {
        guard let o = obj else { return "nil" }
        let idStr = o.objectID.isTemporaryID ? "temp" : "perm"
        return "\(type(of: o))(\(idStr)) id=\(o.objectID.uriRepresentation().absoluteString)"
    }

    
}

