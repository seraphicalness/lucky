import Foundation

enum FriendAPI {
    /// 친구 목록 조회
    static func fetchFriends(token: String) async throws -> [FriendResponse] {
        try await APIClient.shared.request(
            path: "/api/v1/friends",
            token: token,
            responseType: [FriendResponse].self
        )
    }

    /// 받은 친구 신청 목록
    static func fetchPendingRequests(token: String) async throws -> [FriendRequestResponse] {
        try await APIClient.shared.request(
            path: "/api/v1/friends/requests/pending",
            token: token,
            responseType: [FriendRequestResponse].self
        )
    }

    /// 친구 신청 보내기
    static func sendRequest(token: String, toUserId: Int) async throws -> FriendRequestResponse {
        try await APIClient.shared.request(
            path: "/api/v1/friends/request",
            method: "POST",
            token: token,
            body: FriendRequestSendRequest(toUserId: toUserId),
            responseType: FriendRequestResponse.self
        )
    }

    /// 친구 신청 수락/거절
    static func respondRequest(token: String, requestId: Int, action: String) async throws -> FriendRequestResponse {
        try await APIClient.shared.request(
            path: "/api/v1/friends/request/respond",
            method: "POST",
            token: token,
            body: FriendRequestActionRequest(requestId: requestId, action: action),
            responseType: FriendRequestResponse.self
        )
    }
}
