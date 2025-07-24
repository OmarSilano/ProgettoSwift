import SwiftUI
import CoreData

struct SavedWorkoutDetailView: View {
    let workoutID: NSManagedObjectID
    @Environment(\.managedObjectContext) private var context

    @FetchRequest var fetchedWorkout: FetchedResults<Workout>
    @State private var expandedDayID: UUID? = nil
    @State private var selectedDay: WorkoutDay?
    @State private var showActionSheet = false
    @State private var completedTodayIDs: Set<UUID> = []
    @State private var shareURL: URL?
    
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToEdit = false

    init(workoutID: NSManagedObjectID) {
        self.workoutID = workoutID
        _fetchedWorkout = FetchRequest<Workout>(
            entity: Workout.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "SELF == %@", workoutID),
            animation: .default
        )
    }

    var body: some View {
        if let workout = fetchedWorkout.first {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: – Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title3)
                        }

                        Spacer()

                        Text(workout.name ?? "Workout")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)

                        Spacer()

                        NavigationLink(destination: EditWorkoutView(workout: workout), isActive: $navigateToEdit) {
                            Button {
                                navigateToEdit = true
                            } label: {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color("FourthColor"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // MARK: – Immagine
                    if workout.category != nil {
                        DefaultWorkoutImageView(imageName: workout.pathToImage)
                    } else {
                        UserWorkoutImageView(imageName: workout.pathToImage)
                    }

                    // MARK: – Info
                    HStack {
                        Text("\(workout.days) Days")
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(workout.weeks) Weeks")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    Divider().background(Color.gray)

                    // MARK: – Giorni
                    if let days = workout.workoutDay?.allObjects as? [WorkoutDay] {
                        ForEach(days.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })) { day in
                            WorkoutDayRowViewWithActionSheet(
                                day: day,
                                isCompletedToday: completedTodayIDs.contains(day.id ?? UUID()),
                                expandedDayID: $expandedDayID,
                                onLongPress: {
                                    selectedDay = day
                                    showActionSheet = true
                                }
                            )
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .sheet(item: $shareURL) { url in
                ShareSheet(items: [url]) {
                    shareURL = nil
                }
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
            .confirmationDialog("Day Actions", isPresented: $showActionSheet, titleVisibility: .visible) {
                if let selectedDay = selectedDay, let id = selectedDay.id {
                    if completedTodayIDs.contains(id) {
                        Button("Mark as Not Done", role: .destructive) {
                            let manager = WorkoutDayCompletedManager(context: context)
                            manager.removeCompletion(for: selectedDay, on: Date())
                            completedTodayIDs.remove(id)
                        }
                    } else {
                        Button("Mark as Done") {
                            let manager = WorkoutDayCompletedManager(context: context)
                            manager.markAsCompleted(workoutDay: selectedDay, date: Date())
                            completedTodayIDs.insert(id)
                        }
                    }
                }

                Button("Edit") {
                    navigateToEdit = true
                }
                Button("Share") {
                    if let selectedDay = selectedDay {
                        shareDay(selectedDay) // ✅ chiamiamo la funzione
                    }
                }
                Button("Delete", role: .destructive) { /* Da implementare */ }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                let manager = WorkoutDayCompletedManager(context: context)
                let completions = manager.fetchCompletionsLastNDays(n: 7)
                let today = Calendar.current.startOfDay(for: Date())

                completedTodayIDs = Set(
                    completions
                        .filter {
                            guard let day = $0.workoutDay,
                                  let dayID = day.id,
                                  Calendar.current.isDate($0.date ?? Date.distantPast, inSameDayAs: today)
                            else { return false }
                            return true
                        }
                        .compactMap { $0.workoutDay?.id }
                )
            }
            .navigationBarBackButtonHidden(true)

        } else {
            Text("Workout not found")
                .foregroundColor(.gray)
                .padding()
        }
        
        
    }
    
    
    
    private func shareDay(_ day: WorkoutDay) {
        let text = day.toPlainText()
        
        // Salva come file temporaneo
        if let url = saveAsTextFile(text, filename: day.name ?? "WorkoutDay") {
            print("✅ File pronto per condivisione: \(url.path)")
            shareURL = url
        }
    }
}



struct WorkoutDayRowViewWithActionSheet: View {
    let day: WorkoutDay
    let isCompletedToday: Bool
    @Binding var expandedDayID: UUID?
    let onLongPress: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Spacer()
                
                VStack(spacing: 2) {
                    Text(day.name ?? "Unnamed Day")
                        .font(.headline)
                        .foregroundColor(isCompletedToday ? Color("PrimaryColor") : .white)
                    
                    Text(muscleGroupsText(from: day))
                        .font(.subheadline)
                        .foregroundColor(isCompletedToday ? Color("PrimaryColor") : Color("SubtitleColor"))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: expandedDayID == day.id ? "chevron.up" : "plus")
                    .foregroundColor(isCompletedToday ? Color("SecondaryColor") : .white)
                
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    toggleDay(day)
                }
            }
            .onLongPressGesture {
                onLongPress()
            }
            
            
            
            if expandedDayID == day.id {
                if let details = day.workoutDayDetail?.allObjects as? [WorkoutDayDetail] {
                    ForEach(details, id: \.id) { detail in
                        WorkoutExerciseDetailView(detail: detail, isCompletedToday: isCompletedToday)
                    }
                    
                }
            }
            
            Divider().background(Color.gray.opacity(0.3))
        }
        .background(isCompletedToday ? Color("SecondaryColor") : Color.clear)
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func toggleDay(_ day: WorkoutDay) {
        guard let id = day.id else { return }
        expandedDayID = (expandedDayID == id) ? nil : id
    }
    
    private func muscleGroupsText(from day: WorkoutDay) -> String {
        guard let details = day.workoutDayDetail?.allObjects as? [WorkoutDayDetail] else { return "—" }
        let allGroups = details.compactMap { $0.exercise?.muscle }
        let uniqueGroups = Array(Set(allGroups)).prefix(2)
        var text = uniqueGroups.joined(separator: " • ")
        if allGroups.count > 2 { text += " ..." }
        return text
    }
    
}


