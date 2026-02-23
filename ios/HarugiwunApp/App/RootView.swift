import SwiftUI

final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userId: Int?

    var isLoggedIn: Bool { token != nil }
}

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            if session.isLoggedIn {
                FortuneView()
            } else {
                LoginView()
            }
        }
    }
}
