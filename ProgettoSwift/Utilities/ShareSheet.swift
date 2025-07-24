import SwiftUI
import UIKit
import Foundation

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

func saveAsTextFile(_ text: String, filename: String) -> URL? {
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(filename).txt")
    do {
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
        print("✅ File TXT salvato in: \(fileURL.path)")
        return fileURL
    } catch {
        print("❌ Errore salvataggio file: \(error)")
        return nil
    }
}

func createWorkoutFile(_ workout: Workout) -> URL? {
    let text = workout.toPlainText()
    let filename = workout.name?.replacingOccurrences(of: " ", with: "_") ?? "Workout"
    return saveAsTextFile(text, filename: filename)
}

func createWorkoutDayFile(_ day: WorkoutDay) -> URL? {
    let text = day.toPlainText()
    let filename = day.name?.replacingOccurrences(of: " ", with: "_") ?? "WorkoutDay"
    return saveAsTextFile(text, filename: filename)
}
