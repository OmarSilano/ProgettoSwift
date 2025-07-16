import SwiftUI

struct AddWorkoutView: View {
    @Environment(\.managedObjectContext) var context
    
    @State private var workoutName: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("CREATE WORKOUT")
                    .font(Font.titleLarge)
                    .bold()
                    .foregroundColor(Color("FourthColor"))
                
                HStack {
                    TextField("", text: $workoutName)
                        .padding(10)
                        .background(Color("ThirdColor"))    // sfondo personalizzato
                        .foregroundColor(Color("FourthColor"))  // colore testo
                        .cornerRadius(8)

                    
                    if !workoutName.isEmpty {
                        Button(action: {
                            workoutName = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color("SecondaryColor"))
                        }
                        .buttonStyle(BorderlessButtonStyle()) // per evitare che catturi tutto il tap
                    }
                }
                .padding(.horizontal)

                
                // Qui l'icona immagine o preview immagine selezionata
                Button {
                    isShowingImagePicker = true
                } label: {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color("PrimaryColor"))
                            .background(Color("SecondaryColor"))
                            .cornerRadius(10)
                            .padding()

                    }
                }
                .buttonStyle(PlainButtonStyle()) // Per togliere effetti button default
                
                Spacer()
            }
            .padding()
            .background(Color("PrimaryColor").edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}
