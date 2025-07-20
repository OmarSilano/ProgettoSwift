import SwiftUI

struct WorkoutDayRowView: View {
    let day: WorkoutDay
    @Binding var expandedDayID: UUID?

    var overrideName: String? = nil // nome alternativo opzionale (utile nel calendario)
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {
                withAnimation { toggleDay(day) }
            }) {
                HStack {
                    Spacer()

                    VStack(spacing: 2) {
                        Text(overrideName ?? (day.name ?? "Unnamed Day"))
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
                        WorkoutExerciseDetailView(detail: detail, isCompletedToday: nil)
                    }
                }
            }

            Divider().background(Color.gray.opacity(0.3))
        }
        .padding(.horizontal)
        .background(Color("PrimaryColor"))
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
