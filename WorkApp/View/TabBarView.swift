import SwiftUI

class TabRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isTabBarHidden: Bool = false
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
        NavigationStack {
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

                ToolsView()
                    .tabItem { Label("TOOLS", systemImage: "gearshape") }
                    .tag(3)
            }
            .tint(Color("SecondaryColor"))
        }
        .environmentObject(tabRouter)
    }
}




// MARK: - Anteprima
#Preview {
    TabBarView()
}
