import Foundation

struct PointBalanceResponse: Codable {
    let currentPoints: Int
    let dailyAdCount: Int
    let message: String
}

struct AdRewardRequest: Codable {
    let adUnitId: String
}

struct PurchaseRequest: Codable {
    let productId: String
    let amount: Int
    let receiptData: String
}

struct StoreProduct: Identifiable {
    let id: String
    let name: String
    let points: Int
    let price: String
}
