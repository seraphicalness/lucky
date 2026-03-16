import Foundation

// MARK: - Friend

struct FriendResponse: Codable, Identifiable {
    var id: Int { friendUserId }
    let friendUserId: Int
    let nickname: String
    let friendSince: String
}

struct FriendListResponse: Codable {
    let friends: [FriendResponse]
}

// MARK: - Friend Request

struct FriendRequestResponse: Codable, Identifiable {
    var id: Int { Int(requestId) }
    let requestId: Int
    let fromUserId: Int
    let fromUserNickname: String
    let toUserId: Int
    let toUserNickname: String
    let status: String
    let createdAt: String
}

struct PendingRequestListResponse: Codable {
    let requests: [FriendRequestResponse]
}

struct FriendRequestSendRequest: Codable {
    let toUserId: Int
}

struct FriendRequestActionRequest: Codable {
    let requestId: Int
    let action: String // "ACCEPTED" or "REJECTED"
}
