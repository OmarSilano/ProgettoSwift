import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        NavigationLink(destination: ExerciseDetailView(objectID: exercise.objectID)) {
            HStack(spacing: 12) {
                
                // Immagine se disponibile, altrimenti placeholder
                if let path = exercise.pathToImage, !path.isEmpty {
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
                
                // Nome esercizio
                Text(exercise.name ?? "Exercise")
                    .foregroundColor(.white)
                    .font(.subheadline)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
