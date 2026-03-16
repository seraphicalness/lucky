import Foundation

enum AuthAPI {
    static func socialLogin(request: SocialLoginRequest) async throws -> SocialLoginResponse {
        let body = try JSONEncoder().encode(request)
        return try await APIClient.shared.request(
            path: "api/v1/auth/social/login",
            method: "POST",
            body: body,
            responseType: SocialLoginResponse.self
        )
    }
}
