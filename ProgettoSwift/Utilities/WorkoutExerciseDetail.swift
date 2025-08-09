import SwiftUI

struct WorkoutExerciseDetailView: View {
    let detail: WorkoutDayDetail
    let isCompletedToday: Bool?

    var body: some View {
        let completed = isCompletedToday ?? false // fallback a false se nil

        NavigationLink(destination: ExerciseDetailView(objectID: detail.exercise!.objectID)) {  //objectID: exercise.objectID
            HStack(spacing: 12) {
                if let s = detail.exercise?.pathToImage, !s.isEmpty,
                   let ui = (FileManager.default.fileExists(atPath: s)
                             ? UIImage(contentsOfFile: s)      
                             : UIImage(named: s))
                {
                    Image(uiImage: ui)
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
                        .foregroundColor(completed ? Color("PrimaryColor") : .white)
                        .font(.subheadline)

                    Text(detail.typology?.name ?? "Method")
                        .foregroundColor(completed ? Color("PrimaryColor") : Color("SubtitleColor"))
                        .font(.caption)
                }

                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
