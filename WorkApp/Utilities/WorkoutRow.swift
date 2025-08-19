import SwiftUI

struct WorkoutRow: View {
    let workout: Workout

    private func imageForDisplay() -> UIImage? {
        guard let s = workout.pathToImage, !s.isEmpty else { return nil }
        if FileManager.default.fileExists(atPath: s) {
            return UIImage(contentsOfFile: s)
        }
        return UIImage(named: s)
    }

    private var daysLabel: String {
        let relCount = workout.workoutDay?.count ?? 0
        let daysCount = relCount > 0 ? relCount : Int(workout.days)
        return "\(daysCount) days • \(workout.weeks) weeks"
    }

    var body: some View {
        HStack(spacing: 16) {
            if let uiImage = imageForDisplay() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("FourthColor"))
                    .background(Color("ThirdColor"))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name ?? "Unnamed")
                    .foregroundColor(Color("FourthColor"))
                    .font(.headline)
                    .lineLimit(1)

                Text(daysLabel)
                    .font(.subheadline)
                    .foregroundColor(Color("SubtitleColor"))
            }

            Spacer()
        }
        .padding(12)
        .cornerRadius(12)
    }
}
