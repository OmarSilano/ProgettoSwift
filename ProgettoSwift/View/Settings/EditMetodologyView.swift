import SwiftUI
import CoreData

struct EditMetodologyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    var typology: Typology
    
    @State private var title: String
    @State private var description: String
    
    @State private var showAlert = false
    
    init(typology: Typology) {
        self.typology = typology
        _title = State(initialValue: typology.name ?? "")
        _description = State(initialValue: typology.detail ?? "")
    }
    
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
                
                Text("EDIT METODOLOGY")
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
            
            // MARK: - Save Button
            Button(action: {
                editMetodology()
            }) {
                Text("SAVE CHANGES")
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
                    message: Text("Please insert a title for the methodology."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: - Logic to Edit Typology
    private func editMetodology() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            showAlert = true
            return
        }
        
        let typologyManager = TypologyManager(context: context)
        typologyManager.updateTypology(
            typology,
            name: trimmedTitle,
            detail: trimmedDescription.isEmpty ? nil : trimmedDescription
        )
        
        presentationMode.wrappedValue.dismiss()
    }

}
