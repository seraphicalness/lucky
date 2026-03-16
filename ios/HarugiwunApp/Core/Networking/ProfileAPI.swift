import Foundation

enum ProfileAPI {
    /// 프로필 조회
    static func fetchProfile(token: String) async throws -> ProfileResponse {
        try await APIClient.shared.request(
            path: "/api/v1/profile",
            token: token,
            responseType: ProfileResponse.self
        )
    }

    /// 프로필 수정
    static func updateProfile(token: String, request: ProfileUpdateRequest) async throws -> ProfileResponse {
        try await APIClient.shared.request(
            path: "/api/v1/profile",
            method: "PUT",
            token: token,
            body: request,
            responseType: ProfileResponse.self
        )
    }

    /// 사주 정보 조회 (생년월일이 등록된 경우만 호출)
    static func fetchSaju(token: String) async throws -> SajuResponse {
        try await APIClient.shared.request(
            path: "/api/v1/profile/saju",
            token: token,
            responseType: SajuResponse.self
        )
    }
}
