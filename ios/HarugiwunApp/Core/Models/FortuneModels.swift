import Foundation

struct FortuneWidgetResponse: Codable {
    let date: Date
    let pending: Bool
    let pendingMessage: String?
    let totalScore: Int?
    let luckyColor: String?
    let luckyNumber: Int?
    let summary: String?
}

struct FortuneDetailResponse: Codable {
    let date: Date
    let totalScore: Int
    let moneyScore: Int
    let loveScore: Int
    let healthScore: Int
    let workScore: Int
    let socialScore: Int
    let luckyColor: String
    let luckyNumber: Int
    let summary: String
    let detailText: String
}

// MARK: - Tarot Card (서버: /api/v1/fortune/today/tarot)
struct TarotCardResponse: Codable {
    let name: String
    let meaning: String
    let description: String
    let imageUrl: String
    let picked: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case meaning
        case description
        case imageUrl
        case picked
    }
}
