import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // Titolo
                Text("SETTINGS")
                    .font(.titleLarge)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer().frame(height: 40)
                
                VStack(alignment: .center, spacing: 10) {
                    
                    // Training Metodology
                    NavigationLink(destination: TrainingMetodologyView()) {
                        HStack {
                            Text("Training Metodology")
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
                    NavigationLink(destination: BannedExercisesView()) {
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
                    
                    NavigationLink(destination: ChatBotView()) {
                        HStack {
                            Text("Chiedi a Atlas🤖")
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
}

struct BannedExercisesView: View {
    var body: some View {
        Text("Banned Exercises List details here.")
            .foregroundColor(.white)
            .background(Color("PrimaryColor"))
    }
}

