import Foundation

enum FortuneAPI {
    static func fetchToday(token: String) async throws -> FortuneDetailResponse {
        try await APIClient.shared.request(
            path: "api/v1/fortune/today",
            token: token,
            responseType: FortuneDetailResponse.self
        )
    }
}
