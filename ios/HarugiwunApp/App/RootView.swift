import SwiftUI

final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userId: Int?
    @Published var points: Int = 0
    @Published var needsOnboarding = false

    var isLoggedIn: Bool { token != nil }

    func checkIn() async {
        guard let token = token else { return }
        do {
            let result = try await APIClient.shared.request(
                path: "/api/v1/attendance/check-in",
                method: "POST",
                token: token,
                responseType: CheckInResponse.self
            )
            DispatchQueue.main.async {
                self.points = result.currentPoints
                if result.success {
                    print("Check-in success: \(result.message)")
                }
            }
        } catch {
            print("Check-in failed: \(error)")
        }
    }
}

struct CheckInResponse: Codable {
    let success: Bool
    let currentPoints: Int
    let message: String
}

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isLoggedIn {
                MainTabView()
            } else if session.needsOnboarding {
                OnboardingView()
            } else {
                LoginView()
            }
        }
        .task {
            if session.isLoggedIn {
                await session.checkIn()
            }
        }
    }
}
