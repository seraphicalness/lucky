import Foundation

struct ProfileResponse: Codable {
    let userId: Int
    let nickname: String
    let birthDate: String?
    let birthTime: String?
}

struct ProfileUpdateRequest: Codable {
    let nickname: String?
    let birthDate: String
    let birthTime: String?
}
