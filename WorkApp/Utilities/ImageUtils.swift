import UIKit



func saveImageToDocuments(_ image: UIImage, imageName: String) -> String? {
    
    createImagesDirectoryIfNeeded()
    
    guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let imagesDirectory = documentsURL.appendingPathComponent("WorkoutImages")
    let fileURL = imagesDirectory.appendingPathComponent(imageName)

    do {
        try data.write(to: fileURL)
        return fileURL.path
    } catch {
        print("❌ Errore nel salvataggio immagine: \(error)")
        return nil
    }
}


func saveDefaultImageToDocuments(imageName: String) -> String? {
    // all'inizio l'immagine è nel bundle
    guard let image = UIImage(named: imageName) else {
        print("❌ Immagine '\(imageName)' non trovata nel bundle")
        return nil
    }

    // con UUID evitiamo che ci siano imagePaths uguali
    let uniqueFileName = UUID().uuidString + ".jpg"

    // salva nella cartella WorkoutImages
    if let savedPath = saveImageToDocuments(image, imageName: uniqueFileName) {
        print("✅ Immagine di default salvata in: \(savedPath)")
        return savedPath
    } else {
        return nil
    }
}


func loadImage(from path: String) -> UIImage? {
    let url = URL(fileURLWithPath: path)
    guard let data = try? Data(contentsOf: url) else { return nil }
    return UIImage(data: data)
}

private func createImagesDirectoryIfNeeded() {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let imagesDirectory = documentsURL.appendingPathComponent("WorkoutImages")

    if !fileManager.fileExists(atPath: imagesDirectory.path) {
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }
}
