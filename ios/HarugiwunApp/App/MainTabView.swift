import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home = "홈"
        case fortune = "운세"
        case friends = "친구"
        case profile = "내 정보"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(Tab.home.rawValue, systemImage: "house.fill")
            }
            .tag(Tab.home)

            NavigationStack {
                FortuneView()
            }
            .tabItem {
                Label(Tab.fortune.rawValue, systemImage: "sparkles")
            }
            .tag(Tab.fortune)

            NavigationStack {
                FriendsView()
            }
            .tabItem {
                Label(Tab.friends.rawValue, systemImage: "person.2.fill")
            }
            .tag(Tab.friends)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(Tab.profile.rawValue, systemImage: "person.fill")
            }
            .tag(Tab.profile)
        }
        .tint(AppTheme.tabGreen)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
