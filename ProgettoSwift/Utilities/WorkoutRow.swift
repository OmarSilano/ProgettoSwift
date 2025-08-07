import SwiftUI

struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 16) {
            // Immagine
            if let imgPath = workout.pathToImage,
                !imgPath.isEmpty,
               FileManager.default.fileExists(atPath: imgPath),
                let uiImage = UIImage(contentsOfFile: imgPath) {
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

            // Testi
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.name ?? "Unnamed")
                    .foregroundColor(Color("FourthColor"))
                    .font(.headline)
                    .lineLimit(1)

                Text("\(workout.days) days • \(workout.weeks) weeks")
                    .font(.subheadline)
                    .foregroundColor(Color("SubtitleColor"))
            }

            Spacer()
        }
        .padding(12)
        .cornerRadius(12)
    }
}
