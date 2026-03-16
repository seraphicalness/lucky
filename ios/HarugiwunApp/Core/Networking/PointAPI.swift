import Foundation

enum PointAPI {
    static func fetchBalance(token: String) async throws -> PointBalanceResponse {
        try await APIClient.shared.request(
            path: "api/v1/points/balance",
            token: token,
            responseType: PointBalanceResponse.self
        )
    }

    static func claimAdReward(token: String) async throws -> PointBalanceResponse {
        let body = try JSONEncoder().encode(AdRewardRequest(adUnitId: "rewarded-ad-unit-id"))
        return try await APIClient.shared.request(
            path: "api/v1/points/ad-reward",
            method: "POST",
            token: token,
            body: body,
            responseType: PointBalanceResponse.self
        )
    }

    static func purchasePoints(token: String, productId: String, amount: Int) async throws -> PointBalanceResponse {
        let body = try JSONEncoder().encode(PurchaseRequest(
            productId: productId,
            amount: amount,
            receiptData: "mock-receipt-data"
        ))
        return try await APIClient.shared.request(
            path: "api/v1/points/purchase",
            method: "POST",
            token: token,
            body: body,
            responseType: PointBalanceResponse.self
        )
    }
}
