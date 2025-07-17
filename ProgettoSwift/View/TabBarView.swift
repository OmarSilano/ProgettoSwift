import SwiftUI

// MARK: - TabRouter per gestire la tab selezionata
class TabRouter: ObservableObject {
    @Published var selectedTab: Int = 0
}

// MARK: - TabView principale
struct TabBarView: View {
    @StateObject private var tabRouter = TabRouter()

    init() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.unselectedItemTintColor = UIColor(named:"TabBarSymbolColor")

        if let tabBarColor = UIColor(named: "TabBarColor") {
            tabBarAppearance.backgroundColor = tabBarColor.withAlphaComponent(0.9)
        } else {
            tabBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        }
    }

    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            ExploreView()
                .tabItem { Label("EXPLORE", systemImage: "safari") }
                .tag(0)

            WorkoutView()
                .tabItem { Label("WORKOUT", systemImage: "dumbbell") }
                .tag(1)

            StatsView()
                .tabItem { Label("STATS", systemImage: "chart.bar") }
                .tag(2)

            SettingsView()
                .tabItem { Label("SETTINGS", systemImage: "gearshape") }
                .tag(3)
        }
        .environmentObject(tabRouter)
        .tint(Color("SecondaryColor"))
    }
}

// MARK: - Anteprima
#Preview {
    TabBarView()
}
