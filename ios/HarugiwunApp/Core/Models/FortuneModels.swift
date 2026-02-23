import Foundation

struct FortuneWidgetResponse: Codable {
    let date: String
    let totalScore: Int
    let luckyColor: String
    let luckyNumber: Int
    let summary: String
}

struct FortuneDetailResponse: Codable {
    let date: String
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
