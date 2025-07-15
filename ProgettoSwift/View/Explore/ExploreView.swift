import SwiftUI

struct Carusel: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct ExploreView: View {
    
    @Environment(\.managedObjectContext) var context
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
    
    var body: some View {}
}

#Preview {
    ExploreView()
}
