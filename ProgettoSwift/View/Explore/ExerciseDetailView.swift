import SwiftUI
import AVKit

struct ExerciseDetailView: View {
    let exercise: Exercise?
    @Environment(\.dismiss) var dismiss
    
    @State private var isPlaying: Bool = true
    @State private var player: AVPlayer? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text(exercise?.name ?? "Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    if let player = player {
                        player.seek(to: .zero)
                        player.play()
                        isPlaying = true
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color("FourthColor"))
                        .font(.title2)
                }
            }
            .padding()
            .background(Color("PrimaryColor"))
            
            // Video Player
            if let path = exercise?.pathToVideo,
               let url = Bundle.main.url(forResource: path, withExtension: nil) {

                // Debug: stampa il path usato
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .onAppear {
                        print("Video path usato per cercare il file: '\(path)'")
                        player = AVPlayer(url: url)
                        player?.play()
                        isPlaying = true
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
                        print("❌ Video non trovato: \(exercise?.pathToVideo ?? "nil")")
                    }
            }


            
            
            
            // Play/Pause
            HStack {
                Button(action: {
                    if let player = player {
                        if isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                        isPlaying.toggle()
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("SecondaryColor"))
                        .clipShape(Circle())
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Description
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Istruzioni:")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(exercise?.instructions ?? "No description available.")
                        .foregroundColor(.white)
                        .font(.body)
                }
                .padding()
            }
            
            Spacer()
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
