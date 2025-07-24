import SwiftUI

struct PermissionsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    @State var isNotificationOn: Bool = false
    @State var isGalleryOn: Bool = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                // Pulsante indietro
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("FourthColor"))
                        .font(.title2)
                }
                
                Spacer()
                
                // Titolo centrato con ZStack
                ZStack {
                    Text("PERMISSIONS")
                        .foregroundColor(Color("FourthColor"))
                        .font(Font.titleLarge)
                    
                    // Elemento invisibile per bilanciare lo spazio
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.left")
                            .opacity(0) // Invisibile
                            .font(.title2)
                    }
                }
                .frame(maxWidth: .infinity)
                
            }
            .padding()
            
            Spacer()
            
            Form {
                
                Toggle("Notifications", systemImage: "bell.fill", isOn: $isNotificationOn)
                    .tint(Color("SecondaryColor"))
                
                Toggle("Gallery", systemImage: "bell.fill", isOn: $isGalleryOn)
                    .tint(Color("SecondaryColor"))
                
            }
            
        }
    }
}

#Preview {
    PermissionsView()
}
