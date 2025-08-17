import SwiftUI
import CoreData

// MARK: - Row Giorno
struct WorkoutDayRow_CoreData: View {
    @ObservedObject var day: WorkoutDay
    @Binding var expandedDayID: NSManagedObjectID?
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    private var musclesSubtitle: String {
        // prendi i muscoli dagli esercizi dei dettagli già collegati al day
        let groups = day.sortedDetails
            .compactMap { $0.exercise?.muscle }
            .compactMap { MuscleGroup(rawValue: $0) }
        
        var seen = Set<MuscleGroup>()
        let orderedUnique = groups.filter { seen.insert($0).inserted }
        
        let names = orderedUnique.map { $0.rawValue }
        guard !names.isEmpty else { return "" }
        let head = names.prefix(3).joined(separator: " • ")
        
        return names.count > 3 ? head + " ..." : head
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Circle())
                
                VStack(spacing: 2) {
                    Text(day.name ?? "Unnamed Day")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if !musclesSubtitle.isEmpty {
                        Text(musclesSubtitle)   // <— ora arriva dai dettagli
                            .font(.subheadline)
                            .foregroundColor(Color("SubtitleColor"))
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { toggleExpansion() } }
                
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("ThirdColor"))
            .contentShape(Rectangle())
            .onTapGesture { withAnimation { toggleExpansion() } }
            
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func toggleExpansion() {
        expandedDayID = (expandedDayID == day.objectID) ? nil : day.objectID
    }
}


// MARK: - Row Esercizio
struct WorkoutExercisePreviewRow_CoreData: View {
    @ObservedObject var detail: WorkoutDayDetail
    
    var body: some View {
        HStack(spacing: 12) {
            // Immagine
            if let exercise = detail.exercise,
               let path = exercise.pathToImage, !path.isEmpty,
               let url = Bundle.main.url(forResource: (path as NSString).deletingPathExtension,
                                         withExtension: (path as NSString).pathExtension),
               let uiImage = UIImage(contentsOfFile: url.path) {

                Image(uiImage: uiImage)
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
