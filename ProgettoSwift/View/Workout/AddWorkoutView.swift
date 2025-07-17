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

                
                // Sezione immagine + image picker
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(Color("FourthColor"))
                            .background(Color("PrimaryColor"))
                            .cornerRadius(10)
                    }
                    
                    // Bottone centrato sopra l'immagine
                    Button {
                        isShowingImagePicker = true
                    } label: {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color("PrimaryColor"))
                            .padding(10)
                            .background(Color("SecondaryColor"))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
                .frame(height: 200)

                Spacer()
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("Days")
                            .foregroundColor(Color("FourthColor"))
                            .font(.headline)
                        
                        TextField("0", text: .constant(""))
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color("ThirdColor"))
                            .foregroundColor(Color("FourthColor"))
                            .cornerRadius(8)
                            .frame(width: 100)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Weeks")
                            .foregroundColor(Color("FourthColor"))
                            .font(.headline)
                        
                        TextField("0", text: .constant(""))
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color("ThirdColor"))
                            .foregroundColor(Color("FourthColor"))
                            .cornerRadius(8)
                            .frame(width: 100)
                    }
                }
                .padding(.top, 10)

            }
            .padding()
            .background(Color("PrimaryColor").edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}
