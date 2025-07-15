import SwiftUI

struct CategoryCard: Identifiable {
    let id = UUID()
    let category: Category
    let imageName: String
    let description: String
}


import SwiftUI

struct ExploreView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var selectedTab = "Workouts"
    
    private let categories: [CategoryCard] = Category.allCases.map {
        CategoryCard(category: $0, imageName: $0.rawValue, description: "Explore \($0.rawValue) workouts.")
    }
    
    init() {
        let segmentedAppearance = UISegmentedControl.appearance()
        segmentedAppearance.selectedSegmentTintColor = UIColor(named: "SecondaryColor")
        segmentedAppearance.backgroundColor = UIColor(named: "TabBarColor")?.withAlphaComponent(0.9)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "FourthColor")], for: .normal)
        segmentedAppearance.setTitleTextAttributes([.foregroundColor: UIColor(named: "PrimaryColor")], for: .selected)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("EXPLORE")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("FourthColor"))
                    .padding(.top, 20)
                
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Workouts").tag("Workouts")
                    Text("Exercises").tag("Exercises")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                Spacer()
                
                if selectedTab == "Workouts" {
                    TabView {
                        ForEach(categories) { card in
                            NavigationLink(destination: ExploreWorkoutsView(workoutCategory: card.category)) {
                                VStack(spacing: 10) {
                                    Image(card.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 200)
                                        .clipped()
                                        .cornerRadius(20)
                                    
                                    Text(card.category.rawValue)
                                        .font(.title2)
                                        .foregroundColor(Color("SecondaryColor"))
                                    
                                    Text(card.description)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 300)
                } else {
                    // TODO: ExerciseExploreView
                    Text("Exercise explorer coming soon!")
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .background(Color("PrimaryColor"))
        }
    }
}




#Preview {
    ExploreView()
}
