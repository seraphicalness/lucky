import Foundation

struct SocialLoginRequest: Encodable {
    let providerUserId: String
    let nickname: String?
    let birthDate: String?       // "YYYY-MM-DD"
    let birthTime: String?       // "HH:mm:ss" or nil
    let birthCalendarType: String? // "SOLAR" or "LUNAR"
    let birthIsLeapMonth: Bool?
    let gender: String?          // "MALE" or "FEMALE"
}

struct SocialLoginResponse: Decodable {
    let userId: Int
    let token: String
}
