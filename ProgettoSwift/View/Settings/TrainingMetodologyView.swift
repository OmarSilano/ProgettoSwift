import SwiftUI

struct TrainingMetodologyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Sample Data
    
    struct Metodology: Identifiable {
        let id = UUID()
        var title: String
        var description: String?
        let isDefault: Bool
    }
    
    @State private var expandedMetodologyID: UUID? = nil
    @State private var selectedMetodologyIndex: Int? = nil
    
    
    let defaultMetodologies: [Metodology] = [
        Metodology(title: "4x10", description: "4 sets of 10 reps.", isDefault: true),
        Metodology(title: "8x4x4", description: "8 sets of 4 reps x 4 exercises.", isDefault: true),
        Metodology(title: "Piramidale", description: "Increasing weights, decreasing reps.", isDefault: true),
        Metodology(title: "Piramidale Inverso", description: "Decreasing weights, increasing reps.", isDefault: true)
    ]
    
    @State private var userMetodologies: [Metodology] = [
        Metodology(title: "My metodology 1", description: "Custom description 1.", isDefault: false),
        Metodology(title: "My metodology 2", description: nil, isDefault: false)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Title with Back Button
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
                        
                        // MARK: - Default Section
                        Text("DEFAULT")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        VStack(spacing: 1) {
                            ForEach(defaultMetodologies) { metodology in
                                MetodologyRow(
                                    metodology: metodology,
                                    expandedID: $expandedMetodologyID,
                                    userMetodologies: .constant([]), // Pass dummy for default metodologies
                                    canEdit: false
                                )
                            }
                        }
                        
                        // MARK: - Your Metodology Section
                        Text("YOUR METODOLOGY")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        VStack(spacing: 1) {
                            ForEach(userMetodologies.indices, id: \.self) { index in
                                MetodologyRow(
                                    metodology: userMetodologies[index],
                                    expandedID: $expandedMetodologyID,
                                    userMetodologies: $userMetodologies,
                                    canEdit: true
                                )
                            }
                        }
                        
                        Spacer().frame(height: 100) // for bottom button spacing
                    }
                }
                
                // MARK: - Add Metodology Button
                NavigationLink(destination: AddMetodologyView(userMetodologies: $userMetodologies)) {
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
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
            .toolbar(.hidden, for: .tabBar)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Metodology Row View

struct MetodologyRow: View {
    let metodology: TrainingMetodologyView.Metodology
    @Binding var expandedID: UUID?
    @Binding var userMetodologies: [TrainingMetodologyView.Metodology]
    var canEdit: Bool = false
    
    @State private var showDeleteConfirmation = false
    
    var isExpanded: Bool {
        expandedID == metodology.id
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(metodology.title)
                    .foregroundColor(.white)
                    .padding(.leading)
                
                Spacer()
                
                if canEdit {
                    if let index = userMetodologies.firstIndex(where: { $0.id == metodology.id }) {
                        NavigationLink(
                            destination: EditMetodologyView(
                                metodology: $userMetodologies[index]
                            )
                        ) {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                                .padding(.trailing, 5)
                        }
                    }
                }
                
                Image(systemName: isExpanded ? "minus" : "plus")
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .frame(height: 50)
            .background(Color(.darkGray))
            .onTapGesture {
                withAnimation {
                    if isExpanded {
                        expandedID = nil
                    } else {
                        expandedID = metodology.id
                    }
                }
            }
            .contextMenu {
                if canEdit {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Metodology"),
                    message: Text("Are you sure you want to delete this metodology?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteMetodology()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            if isExpanded {
                VStack(alignment: .leading) {
                    Divider()
                        .background(Color.gray)
                    
                    Text(metodology.description ?? "no description...")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.darkGray))
                }
            }
        }
        .background(Color(.darkGray))
    }
    
    private func deleteMetodology() {
        if let index = userMetodologies.firstIndex(where: { $0.id == metodology.id }) {
            userMetodologies.remove(at: index)
        }
    }
}


#Preview {
    TrainingMetodologyView()
}
