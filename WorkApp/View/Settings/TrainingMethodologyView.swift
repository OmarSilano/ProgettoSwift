import SwiftUI
import CoreData

struct TrainingMethodologyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    // Fetch metodologie default (non modificabili)
    @FetchRequest(
        entity: Typology.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Typology.name, ascending: true)],
        predicate: NSPredicate(format: "isDefault == true"),
    ) var defaultTypologies: FetchedResults<Typology>
    
    // Fetch metodologie utente (modificabili)
    @FetchRequest(
        entity: Typology.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Typology.name, ascending: true)],
        predicate: NSPredicate(format: "isDefault == false"),
    ) var userTypologies: FetchedResults<Typology>
    
    @State private var expandedTypologyID: UUID? = nil
    
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
                                    .frame(width: 44, height: 44, alignment: .leading) // area di tap comoda
                                    .contentShape(Rectangle())
                            }

                            Spacer(minLength: 0)
                        }
                        .overlay(
                            Text("TRAINING METHODOLOGY")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("FourthColor"))
                                .multilineTextAlignment(.center)     // ✅ linee centrate
                                .lineLimit(2)                      // ✅ può andare su più righe
                                .fixedSize(horizontal: false, vertical: true) // evita troncamenti
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 40)            // margine per non “toccare” il back
                            ,
                            alignment: .center
                        )
                        .padding(.top, 20)
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // MARK: - Default Section
                        Text("DEFAULT")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        VStack(spacing: 1) {
                            ForEach(defaultTypologies) { typology in
                                TypologyRow(
                                    typology: typology,
                                    expandedID: $expandedTypologyID,
                                    canEdit: false,
                                    context: context
                                )
                            }
                        }
                        
                        // MARK: - User Section
                        Text("YOUR METODOLOGY")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        VStack(spacing: 1) {
                            ForEach(userTypologies) { typology in
                                TypologyRow(
                                    typology: typology,
                                    expandedID: $expandedTypologyID,
                                    canEdit: true,
                                    context: context
                                )
                            }
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
                
                // MARK: - Add Button
                NavigationLink(destination: AddMetodologyView()) {
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
            .onAppear {
                expandedTypologyID = nil
            }
        }
    }
}


struct TypologyRow: View {
    @ObservedObject var typology: Typology
    @Binding var expandedID: UUID?
    let canEdit: Bool
    let context: NSManagedObjectContext
    
    @State private var showDeleteConfirmation = false
    
    var isExpanded: Bool {
        expandedID == typology.id
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(typology.name ?? "Untitled")
                    .foregroundColor(.white)
                    .padding(.leading)
                
                Spacer()
                
                if canEdit {
                    NavigationLink {
                        EditMetodologyView(typology: typology)
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                            .padding(.trailing, 5)
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
                    expandedID = isExpanded ? nil : typology.id
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
                        deleteTypology()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            if isExpanded {
                VStack(alignment: .leading) {
                    Divider().background(Color.gray)
                    
                    Text(typology.detail?.isEmpty == false ? typology.detail! : "No description...")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.darkGray))
                }
            }
        }
        .background(Color(.darkGray))
    }
    
    private func deleteTypology() {
        let manager = TypologyManager(context: context)
        manager.deleteTypology(typology)
        
    }
}

#Preview {
    TrainingMethodologyView();
}
