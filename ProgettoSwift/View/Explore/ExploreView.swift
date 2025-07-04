import SwiftUI

struct Carusel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: Color
    let imageName: String
}

struct ExploreView: View {
    @State private var selectedTab = "Workouts"
    
    let workouts: [Carusel] = [
        Carusel(title: "HYPERTROPHY", description: "This is the workout description.", color: .green, imageName: "Hypertrophy"),
        Carusel(title: "CARDIO & CORE", description: "This is the workout description.", color: .blue, imageName: "hypertrophyImage"),
        Carusel(title: "FUNCTIONAL FITNESS", description: "This is the workout description.", color: .orange, imageName: "hypertrophyImage"),
        Carusel(title: "HIT", description: "This is the workout description.", color: .red, imageName: "hypertrophyImage")
    ]
    
    var body: some View {
        VStack {
            // Titolo
            Text("EXPLORE")
                .font(.title)
                .bold()
                .padding(.top, 20)
            
            // Toggle tab
            Picker("Select Tab", selection: $selectedTab) {
                Text("Workouts").tag("Workouts")
                Text("Exercises").tag("Exercises")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
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
                            .font(.headline)
                            .foregroundColor(workout.color)
                            .padding(.top, 10)
                        
                        Text(workout.description)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    ExploreView()
}
