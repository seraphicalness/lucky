import SwiftUI

final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var userId: Int?
    @Published var points: Int = 0
    @Published var dailyAdCount: Int = 0
    @Published var needsOnboarding = false
    @Published var todaySummary: String = "오늘도 좋은 하루 되세요"
    @Published var todayTotalScore: Int = 0

    /// 온보딩 완료 전까지 임시 보관하는 Apple Provider ID
    var mockProviderUserId: String = ""

    var isLoggedIn: Bool { token != nil }

    func fetchBalance() async {
        guard let token = token else { return }
        do {
            let response = try await PointAPI.fetchBalance(token: token)
            DispatchQueue.main.async {
                self.points = response.currentPoints
                self.dailyAdCount = response.dailyAdCount
            }
        } catch {
            print("Balance fetch failed: \(error)")
        }
    }

    func claimAdReward() async {
        guard let token = token else { return }
        do {
            let response = try await PointAPI.claimAdReward(token: token)
            DispatchQueue.main.async {
                self.points = response.currentPoints
                self.dailyAdCount = response.dailyAdCount
            }
        } catch {
            print("Ad reward failed: \(error)")
        }
    }

    func purchasePoints(productId: String, amount: Int) async {
        guard let token = token else { return }
        do {
            let response = try await PointAPI.purchasePoints(token: token, productId: productId, amount: amount)
            DispatchQueue.main.async {
                self.points = response.currentPoints
                self.dailyAdCount = response.dailyAdCount
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    /// 애플 로그인 성공 후 호출 — providerUserId를 보관하고 온보딩 화면으로 이동
    func startOnboarding(providerId: String) {
        mockProviderUserId = providerId
        needsOnboarding = true
    }

    /// 온보딩 완료 후 OnboardingView에서 호출 — 토큰을 저장하고 메인 탭으로 이동
    func login(token: String, userId: Int) {
        self.token = token
        self.userId = userId
        self.needsOnboarding = false
        Task { await fetchWidgetFortune() }
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
