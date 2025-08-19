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
                let details = day.sortedDetails
                ForEach(details, id: \.id) { detail in
                    WorkoutExerciseDetailView(detail: detail, isCompletedToday: nil)
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
        guard let ns = day.workoutDayDetail else { return "—" }

        let details: [WorkoutDayDetail] = (ns as? Set<WorkoutDayDetail> ?? [])
            .sorted { ($0.exercise?.muscle ?? "") < ($1.exercise?.muscle ?? "") }

        var seen = Set<String>()
        var orderedUnique: [String] = []
        for d in details {
            if let m = d.exercise?.muscle, !m.isEmpty, !seen.contains(m) {
                seen.insert(m)
                orderedUnique.append(m)
            }
        }

        let shown = orderedUnique.prefix(2)
        if shown.isEmpty { return "—" }

        var text = shown.joined(separator: " • ")
        if orderedUnique.count > 2 { text += " ..." }
        return text
    }

}
