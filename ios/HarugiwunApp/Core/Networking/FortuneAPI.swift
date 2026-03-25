import Foundation

enum FortuneAPI {
    /// 오늘 상세 운세 (앱 진입 시 호출 → lastActiveAt 갱신 + 운세 생성/캐시)
    static func fetchToday(token: String) async throws -> FortuneDetailResponse {
        try await APIClient.shared.request(
            path: "/api/v1/fortune/today",
            token: token,
            responseType: FortuneDetailResponse.self
        )
    }

    /// 위젯용 요약 운세 (이미 생성된 운세만 반환, 없으면 pending)
    static func fetchWidget(token: String) async throws -> FortuneWidgetResponse {
        try await APIClient.shared.request(
            path: "/api/v1/fortune/today/widget",
            token: token,
            responseType: FortuneWidgetResponse.self
        )
    }

    /// 오늘의 타로 카드
    static func fetchTodayTarot(token: String) async throws -> TarotCardResponse {
        try await APIClient.shared.request(
            path: "/api/v1/fortune/today/tarot",
            token: token,
            responseType: TarotCardResponse.self
        )
    }
}
