import SwiftUI
import CoreData

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        
        NavigationStack {
            VStack {
                // Titolo
                Text("SETTINGS")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("FourthColor"))
                    .padding(.top, 20)
                
                Spacer().frame(height: 40)
                
                VStack(alignment: .center, spacing: 10) {
                    
                    // Training Metodology
                    NavigationLink(destination: TrainingMethodologyView()) {
                        HStack {
                            Text("Training Methodology")
                                .foregroundColor(.white)
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 80)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    
                    // Banned Exercises List
                    NavigationLink(destination: BannedExercisesView(
                        
                        onSelect: { ids in unbanExercises(with: ids) }
                        
                    )) {
                        HStack {
                            Text("Banned Exercises List")
                                .foregroundColor(.white)
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 80)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    
                    //ChatBotView
                    NavigationLink(destination: ChatBotView()) {
                        HStack {
                            Text("Ask to Atlas🤖")
                                .foregroundColor(.white)
                                .font(.title3)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 80)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
        }
    }
    
    // MARK: - Actions
    private func unbanExercises(with ids: [NSManagedObjectID]) {
        
        let manager = ExerciseManager(context: context)
        for id in ids {
            if let exercise = try? context.existingObject(with: id) as? Exercise,
               exercise.isBanned {
                manager.toggleBan(for: exercise) // diventa "non bannato"
            }
        }
        
    }
    
    
    
    
}
