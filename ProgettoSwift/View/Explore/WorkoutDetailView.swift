import SwiftUI

// MARK: - View Principale
struct WorkoutDetailView: View {
    let workout: Workout
    @State private var expandedDayID: UUID? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
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
                        .padding(.horizontal)

                    Spacer()

                    Button {
                        // Help action
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color("FourthColor"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                
                // Immagine del workout
                WorkoutImageView(imageName: workout.pathToImage)

                // Info generali
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(workout.weeks) Weeks • \(workout.days ?? 0) Days")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text(workout.difficulty ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Divider().background(Color.gray)

                // Giorni dell'allenamento
                if let days = workout.workoutDay?.allObjects as? [WorkoutDay] {
                    ForEach(days.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })) { day in
                        WorkoutDayRowView(day: day, expandedDayID: $expandedDayID)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .overlay(
            VStack {
                Spacer()
                Button(action: {
                    // TODO: Azione per aggiungere workout
                }) {
                    Text("ADD WORKOUT")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 12)
            }
        )
    }
}

struct WorkoutDayRowView: View {
    let day: WorkoutDay
    @Binding var expandedDayID: UUID?

    var body: some View {
        VStack(spacing: 4) {
            Button(action: {
                withAnimation { toggleDay(day) }
            }) {
                HStack {
                    Spacer()

                    VStack(spacing: 2) {
                        Text(day.name ?? "Unnamed Day")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(muscleGroupsText(from: day))
                            .font(.subheadline)
                            .foregroundColor(Color("SubtitleColor"))
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: expandedDayID == day.id ? "chevron.up" : "plus")
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle()) // permette di cliccare tutta l'area
            }
            .buttonStyle(PlainButtonStyle())

            if expandedDayID == day.id {
                if let details = day.workoutDayDetail?.allObjects as? [WorkoutDayDetail] {
                    ForEach(details, id: \.id) { detail in
                        WorkoutExerciseDetailView(detail: detail)
                    }
                }
            }

            Divider().background(Color.gray.opacity(0.3))
        }
        .padding(.horizontal)
    }

    private func toggleDay(_ day: WorkoutDay) {
        guard let id = day.id else { return }
        expandedDayID = (expandedDayID == id) ? nil : id
    }

    private func muscleGroupsText(from day: WorkoutDay) -> String {
        guard let details = day.workoutDayDetail?.allObjects as? [WorkoutDayDetail] else { return "—" }

        // Ricava i nomi univoci dei gruppi muscolari
        let allGroups = details.compactMap { $0.exercise?.muscle}
        let uniqueGroups = Array(Set(allGroups)).prefix(2) // massimo 2
        var text = uniqueGroups.joined(separator: " • ")
        if allGroups.count > 2 {
            text += " ..."
        }
        return text
    }
}



struct WorkoutExerciseDetailView: View {
    let detail: WorkoutDayDetail

    var body: some View {
        HStack(spacing: 12) {
            if let path = detail.exercise?.pathToImage, !path.isEmpty {
                Image(path)
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
                Text(detail.exercise?.name ?? "Exercise")
                    .foregroundColor(.white)
                    .font(.subheadline)
                Text(detail.typology?.name ?? "Method")
                    .foregroundColor(Color("SubtitleColor"))
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutImageView: View {
    let imageName: String?

    var body: some View {
        Group {
            if let imageName = imageName, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(16)
                    .padding(.horizontal)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 220)
                    .cornerRadius(16)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    )
                    .padding(.horizontal)
            }
        }
    }
}
