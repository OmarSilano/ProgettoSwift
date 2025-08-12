import SwiftUI
import AVKit
import CoreData

struct ExerciseDetailView: View {
    let objectID: NSManagedObjectID
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    
    @State private var exercise: Exercise?
    @State private var player: AVPlayer? = nil
    
    private var exerciseManager: ExerciseManager {
        ExerciseManager(context: context)
    }
    
    var body: some View {
        Group {
            if let exercise = exercise {
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
            } else {
                VStack {
                    Text("Exercise not found")
                        .foregroundColor(.red)
                        .padding()
                    Button("Close") {
                        dismiss()
                    }
                }
                .background(Color("PrimaryColor").ignoresSafeArea())
            }
        }
        .onAppear {
            // Rifetch sicuro dal context
            if let fetchedExercise = try? context.existingObject(with: objectID) as? Exercise {
                self.exercise = fetchedExercise
            } else {
                print("⚠️ Exercise non trovato per ID \(objectID)")
            }
        }
    }
}

// Sottoview per il video
struct ExerciseVideoView: View {
    let pathToVideo: String?
    @State private var player: AVPlayer? = nil
    @State private var isPlaying: Bool = false
    
    var body: some View {
        ZStack {
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
                
                if !isPlaying {
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 250)
                    
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                        .onTapGesture {
                            player?.play()
                            isPlaying = true
                        }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 250)
                    .overlay(
                        Text("Video not yet available.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .onAppear {
                        print("❌ Video non trovato: \(pathToVideo ?? "nil")")
                    }
            }


        }
    }
}

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
