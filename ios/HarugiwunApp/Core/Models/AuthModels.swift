import Foundation

struct SocialLoginRequest: Codable {
    let providerUserId: String
    let nickname: String?
    let birthDate: String?
    let birthTime: String?
}

struct SocialLoginResponse: Codable {
    let userId: Int
    let token: String
}
