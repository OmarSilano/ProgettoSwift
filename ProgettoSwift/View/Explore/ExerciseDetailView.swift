import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    @ObservedObject var exercise: Exercise
    
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
                .frame(width: 70, alignment: .leading)
                
                Spacer()
                
                Text(exercise.name ?? "Exercise")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    exerciseManager.toggleBan(for: exercise)
                }) {
                    Text(exercise.isBanned ? "Unban" : "Ban")
                        .foregroundColor(exercise.isBanned ? .green : .red)
                        .frame(width: 70)
                }
            }
            .padding()
            .background(Color("PrimaryColor"))
            
            ExerciseVideoView(pathToVideo: exercise.pathToVideo)
            
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

// Sottoview isolata per il video, così che non venga ricaricato ad ogni Ban\Unban
struct ExerciseVideoView: View {
    let pathToVideo: String?
    @State private var player: AVPlayer? = nil
    
    var body: some View {
        if let path = pathToVideo,
           let url = Bundle.main.url(forResource: path, withExtension: nil) {
            
            AVPlayerControllerRepresented(player: player ?? AVPlayer(url: url))
                .frame(height: 250)
                .onAppear {
                    if player == nil {
                        player = AVPlayer(url: url)
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
                    print("❌ Video non trovato: \(pathToVideo ?? "nil")")
                }
        }
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
