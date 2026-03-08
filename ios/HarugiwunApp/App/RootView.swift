import SwiftUI

final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userId: Int?
    @Published var needsOnboarding = false

    var isLoggedIn: Bool { token != nil }
}

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        if session.isLoggedIn {
            MainTabView()
        } else if session.needsOnboarding {
            OnboardingView()
        } else {
            LoginView()
        }
    }
}
