import SwiftUI

struct SavedWorkoutDetailView: View {
    let workout: Workout
    @State private var expandedDayID: UUID? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDay: WorkoutDay?
    @State private var showActionSheet = false
    @Environment(\.managedObjectContext) private var viewContext
    @State private var completedTodayIDs: Set<UUID> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: – Header
                HStack {
                    Button {
                    dismiss()
                    } label: {
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

                    Button {
                        // Azione modifica (implementerai dopo)
                    } label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("FourthColor"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // MARK: – Immagine
                if (workout.category != nil) {    //allora è un workout di default
                    DefaultWorkoutImageView(imageName: workout.pathToImage)
                } else {    //...altrimenti è un workout creato dall'utente
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
        
        .background(Color("PrimaryColor").ignoresSafeArea())
//        .navigationBarHidden(true) // nessuna nav bar nativa
        .confirmationDialog("Day Actions", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Mark as Done") {
                if let selectedDay {
                    let manager = WorkoutDayCompletedManager(context: viewContext)
                    manager.markAsCompleted(workoutDay: selectedDay, date: Date())
                    if let id = selectedDay.id {
                        completedTodayIDs.insert(id)
                    }
                }
            }

            Button("Edit") { /* Da implementare */ }
            Button("Share") { /* Da implementare */ }
            Button("Delete", role: .destructive) { /* Da implementare */ }
            Button("Cancel", role: .cancel) {}
        }

        .tint(nil)
        .onAppear {
            let manager = WorkoutDayCompletedManager(context: viewContext)
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
                print("Workout pathToImage: \(workout.pathToImage ?? "nil")")

        }
        .navigationBarBackButtonHidden(true)

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

