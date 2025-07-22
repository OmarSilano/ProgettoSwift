import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State private var player: AVPlayer? = nil
    
    private var exerciseManager: ExerciseManager {
        ExerciseManager(context: context)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text(exercise.name ?? "Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    print("🔍 Stato attuale prima del toggle: \(exercise.isBanned)")
                    exerciseManager.toggleBan(for: exercise)
                    print("✅ Stato dopo il toggle: \(exercise.isBanned)")
                }) {
                    Text(exercise.isBanned ? "Unban" : "Ban")
                        .foregroundColor(exercise.isBanned ? .green : .red)
                }

            }
            .padding()
            .background(Color("PrimaryColor"))
            
            // Video Player
            if let path = exercise.pathToVideo,
               let url = Bundle.main.url(forResource: path, withExtension: nil) {
                
                let localPlayer = AVPlayer(url: url)
                
                AVPlayerControllerRepresented(player: localPlayer)
                    .frame(height: 250)
                    .onAppear {
                        if player == nil {
                            player = localPlayer
                            player?.pause()
                        }
                    }
                    .onDisappear {
                        player?.pause()
                        player?.seek(to: .zero)
                    }
                
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "video.slash")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    )
                    .onAppear {
                        print("❌ Video non trovato: \(exercise.pathToVideo ?? "nil")")
                    }
            }
            
            // Description
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions:")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(exercise.instructions ?? "No description available.")
                        .foregroundColor(.white)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }
}


// Implementa i controlli completi del VideoPlayer
struct AVPlayerControllerRepresented: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
