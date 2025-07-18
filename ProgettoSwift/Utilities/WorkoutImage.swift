import SwiftUI

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
