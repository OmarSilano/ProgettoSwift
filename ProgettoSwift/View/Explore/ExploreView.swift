import SwiftUI

struct Carusel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct ExploreView: View {
    @State private var selectedTab = "Workouts"
    
    let workouts: [Carusel] = [
        Carusel(title: "HYPERTROPHY", description: "This is the workout description.", imageName: "Hypertrophy"),
        Carusel(title: "CARDIO & CORE", description: "This is the workout description.", imageName: "hypertrophyImage"),
        Carusel(title: "FUNCTIONAL FITNESS", description: "This is the workout description.", imageName: "hypertrophyImage"),
        Carusel(title: "HIT", description: "This is the workout description.", imageName: "hypertrophyImage")
    ]
    
    init() {
            let segmentedAppearance = UISegmentedControl.appearance()
            segmentedAppearance.selectedSegmentTintColor = UIColor(named: "SecondaryColor")
            segmentedAppearance.backgroundColor = UIColor(named: "TabBarColor")?.withAlphaComponent(0.9)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "FourthColor")], for: .normal)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "PrimaryColor")], for: .selected)
        }
    
    var body: some View {
        VStack {
            // Titolo
            Text("EXPLORE")
                .font(.titleLarge)
                .foregroundColor(Color("FourthColor"))
                .padding(.top, 20)
            
            
            // Toggle tab
            Picker("Select Tab", selection: $selectedTab) {
                Text("Workouts")
                    .font(.caption)
                    .tag("Workouts")
                Text("Exercises").tag("Exercises")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .tint(Color("SecondaryColor"))
            
            Spacer()
            
            // Carousel swipe
            TabView {
                ForEach(workouts) { workout in
                    VStack {
                        Image(workout.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 200)
                            .cornerRadius(20)
                        
                        Text(workout.title)
                            .font(.titleMedium)
                            .foregroundColor(Color("SecondaryColor"))
                            .padding(.top, 10)
                        
                        Text(workout.description)
                            .font(Font.titleMedium)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            
            Spacer()
        }
        .background(Color("PrimaryColor"))
    }
}

#Preview {
    ExploreView()
}
