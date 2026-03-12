import SwiftUI

final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userId: Int?
    @Published var needsOnboarding = false

    var isLoggedIn: Bool { token != nil }

    private enum Keys {
        static let token = "auth_token"
        static let userId = "auth_user_id"
        static let mockProviderId = "mock_provider_id"
    }

    init() {
        token = UserDefaults.standard.string(forKey: Keys.token)
        let savedId = UserDefaults.standard.integer(forKey: Keys.userId)
        userId = savedId > 0 ? savedId : nil
    }

    func login(token: String, userId: Int) {
        self.token = token
        self.userId = userId
        self.needsOnboarding = false
        UserDefaults.standard.set(token, forKey: Keys.token)
        UserDefaults.standard.set(userId, forKey: Keys.userId)
    }

    func logout() {
        token = nil
        userId = nil
        needsOnboarding = false
        UserDefaults.standard.removeObject(forKey: Keys.token)
        UserDefaults.standard.removeObject(forKey: Keys.userId)
    }

    /// Apple Sign In 전 임시 기기 고유 ID (같은 기기에서 항상 동일 유저)
    var mockProviderUserId: String {
        if let stored = UserDefaults.standard.string(forKey: Keys.mockProviderId) {
            return stored
        }
        let id = "mock-\(UUID().uuidString)"
        UserDefaults.standard.set(id, forKey: Keys.mockProviderId)
        return id
    }
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
