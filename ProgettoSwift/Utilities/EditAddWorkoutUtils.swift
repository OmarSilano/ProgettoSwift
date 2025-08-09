import SwiftUI
import CoreData

// MARK: - Row Giorno
struct WorkoutDayRow_CoreData: View {
    let day: WorkoutDay
    @Binding var expandedDayID: NSManagedObjectID?
    var onDelete: () -> Void
    var onEdit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())

                // Area centrale tappabile
                VStack(spacing: 2) {
                    Text(day.name ?? "Unnamed Day")
                        .font(.headline)
                        .foregroundColor(.white)

                    let subtitle = day.musclesList.map { $0.rawValue }
                    if !subtitle.isEmpty {
                        Text(subtitle.joined(separator: " • "))
                            .font(.subheadline)
                            .foregroundColor(Color("SubtitleColor"))
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { toggleExpansion() } }

                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())
            }
            .padding()
            .background(Color("ThirdColor"))

            // Espansione: mostra i dettagli (exercises)
            if expandedDayID == day.objectID {
                if day.sortedDetails.isEmpty {
                    Text("No exercises yet...")
                        .font(.subheadline)
                        .foregroundColor(Color("SubtitleColor"))
                        .padding(.bottom, 4)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(day.sortedDetails, id: \.objectID) { d in
                            WorkoutExercisePreviewRow_CoreData(detail: d)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color("ThirdColor"))
                    .transition(.opacity)
                }
            }

            Divider().background(Color("ThirdColor").opacity(0.3))
        }
        .padding(.horizontal)
    }

    private func toggleExpansion() {
        expandedDayID = (expandedDayID == day.objectID) ? nil : day.objectID
    }
}

// MARK: - Row Esercizio
struct WorkoutExercisePreviewRow_CoreData: View {
    let detail: WorkoutDayDetail

    var body: some View {
        HStack(spacing: 12) {
            // Placeholder immagine
            if let exercise = detail.exercise,
               let imageName = exercise.pathToImage,
               !imageName.isEmpty,
               UIImage(named: imageName) != nil {
                
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                // Placeholder
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
