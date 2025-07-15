import SwiftUI
import CoreData

struct AddMetodologyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @State private var title: String = ""
    @State private var description: String = ""
    
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - Back Button + Title
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("TRAINING METODOLOGY")
                    .font(.titleLarge)
                    .foregroundColor(.white)
                
                Spacer()
                
                Spacer().frame(width: 44)
            }
            .padding(.top, 20)
            .padding(.horizontal)
            
            // MARK: - Title Field
            VStack(alignment: .leading) {
                Text("Title")
                    .foregroundColor(.white)
                
                TextField("Insert Title...", text: $title)
                    .padding()
                    .background(Color(.darkGray))
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .padding(.horizontal)
            
            // MARK: - Description Field
            VStack(alignment: .leading) {
                Text("Description")
                    .foregroundColor(.white)
                
                TextEditor(text: $description)
                    .frame(height: 150)
                    .padding(4)
                    .background(Color(.darkGray))
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Add Button
            Button(action: {
                if !title.trimmingCharacters(in: .whitespaces).isEmpty {
                    // Crea nuova tipologia nel database
                    _ = Typology(
                        context: context,
                        name: title,
                        detail: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description,
                        isDefault: false
                    )
                    
                    do {
                        try context.save()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Errore durante il salvataggio: \(error)")
                    }
                } else {
                    showAlert = true
                }
            }) {
                Text("ADD METODOLOGY")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("SecondaryColor"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Title"),
                    message: Text("Please insert a title for the metodology."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
