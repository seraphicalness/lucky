import SwiftUI

final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userId: Int?
    @Published var points: Int = 0
    @Published var needsOnboarding = false
    @Published var todaySummary: String = "오늘도 좋은 하루 되세요"
    @Published var todayTotalScore: Int = 0

    var isLoggedIn: Bool { token != nil }

    func login(providerId: String) async {
        let request = SocialLoginRequest(
            providerUserId: providerId,
            nickname: "나희", // TODO: 실제 닉네임 입력
            birthDate: "1998-05-12",
            birthTime: "09:30:00"
        )
        
        do {
            let response = try await AuthAPI.socialLogin(request: request)
            DispatchQueue.main.async {
                self.token = response.token
                self.userId = response.userId
                self.needsOnboarding = false
            }
            // 로그인 직후 위젯 데이터 갱신
            await fetchWidgetFortune()
        } catch {
            print("Login failed: \(error)")
        }
    }

    func fetchWidgetFortune() async {
        guard let token = token else { return }
        do {
            let response = try await APIClient.shared.request(
                path: "api/v1/fortune/today/widget",
                token: token,
                responseType: FortuneWidgetResponse.self
            )
            DispatchQueue.main.async {
                if let score = response.totalScore {
                    self.todayTotalScore = score
                }
                if let sum = response.summary {
                    self.todaySummary = sum
                }
                SharedStore.saveWidgetFortune(response)
            }
        } catch {
            print("Widget fetch failed: \(error)")
        }
    }

    func checkIn() async {
        guard let token = token else { return }
        // ... (기존 checkIn 로직 유지 또는 구현)
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
                await session.fetchWidgetFortune()
            }
        }
    }
}
