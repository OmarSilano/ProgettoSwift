import SwiftUI

struct SettingsView: View {
    var body: some View {
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
                            .font(.title2)
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
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .frame(height: 80)
                    .background(Color.black)
                    .cornerRadius(10)
                }
                
                // Rate App
                Button(action: {
                    // TODO: Implement Rate App action
                }) {
                    HStack {
                        Text("Rate App")
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Image(systemName: "star")
                            .foregroundColor(Color("SecondaryColor"))
                    }
                    .padding(.horizontal)
                    .frame(height: 80)
                    .background(Color.black)
                    .cornerRadius(10)
                }
                
                // Contact Us
                Button(action: {
                    sendEmail()
                }) {
                    HStack {
                        Text("Contact Us")
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Image(systemName: "paperplane")
                            .foregroundColor(Color("SecondaryColor"))
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

struct TrainingMetodologyView: View {
    var body: some View {
        Text("Training Metodology details here.")
            .foregroundColor(.white)
            .background(Color("PrimaryColor"))
    }
}

struct BannedExercisesView: View {
    var body: some View {
        Text("Banned Exercises List details here.")
            .foregroundColor(.white)
            .background(Color("PrimaryColor"))
    }
}

func sendEmail() {
    let email = "v.nunziato2@studenti.unisa.it"
    if let url = URL(string: "mailto:\(email)") {
        UIApplication.shared.open(url)
    }
}


#Preview {
    SettingsView()
}
