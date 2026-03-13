import SwiftUI

struct FriendResponse: Codable, Identifiable {
    var id: Int { friendUserId }
    let friendUserId: Int
    let nickname: String
    let friendSince: String
    let lastActiveAt: String?

    var isTodayActive: Bool {
        guard let lastActiveAt = lastActiveAt else { return false }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        let todayStr = formatter.string(from: Date())
        return lastActiveAt.hasPrefix(todayStr)
    }
}

struct FriendListResponse: Codable {
    let friends: [FriendResponse]
}

struct NudgeResponse: Codable {
    let success: Bool
    let message: String
}

struct FriendsView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var friends: [FriendResponse] = []
    @State private var isLoading = false

    var body: some View {
        List {
            if friends.isEmpty && !isLoading {
                Text("아직 친구가 없습니다.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(friends) { friend in
                    NavigationLink(destination: FriendFortuneView(friend: friend)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(friend.nickname)
                                    .font(.headline)
                                Text(friend.isTodayActive ? "운세 확인 완료" : "아직 안 들어옴")
                                    .font(.subheadline)
                                    .foregroundStyle(friend.isTodayActive ? .green : .secondary)
                            }
                            Spacer()
                            if !friend.isTodayActive {
                                Button("콕 찌르기") {
                                    nudge(friend: friend)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("친구")
        .onAppear { fetchFriends() }
        .refreshable { fetchFriends() }
    }

    private func fetchFriends() {
        guard let token = session.token else { return }
        isLoading = true
        Task {
            do {
                let response = try await APIClient.shared.request(
                    path: "/api/v1/friends",
                    token: token,
                    responseType: FriendListResponse.self
                )
                DispatchQueue.main.async {
                    self.friends = response.friends
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch friends: \(error)")
                isLoading = false
            }
        }
    }

    private func nudge(friend: FriendResponse) {
        guard let token = session.token else { return }
        Task {
            do {
                let _ = try await APIClient.shared.request(
                    path: "/api/v1/friends/nudge",
                    method: "POST",
                    token: token,
                    body: JSONEncoder().encode(["toUserId": friend.friendUserId]),
                    responseType: NudgeResponse.self
                )
                // 알림 등 처리
            } catch {
                print("Nudge failed: \(error)")
            }
        }
    }
}

struct FriendFortuneView: View {
    @EnvironmentObject private var session: SessionStore
    let friend: FriendResponse
    @State private var fortune: FortuneDetailResponse?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let fortune = fortune {
                    Text("\(friend.nickname)님의 오늘 운세")
                        .font(.title2.bold())
                    
                    VStack(spacing: 12) {
                        Text("\(fortune.totalScore)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(.orange)
                        Text("총점")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text(fortune.summary)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()

                    Divider()

                    Text(fortune.detailText)
                        .font(.body)
                        .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue)
                        Text(error)
                            .font(.headline)
                        Button("\(friend.nickname) 콕 찌르기") {
                            nudge()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 100)
                } else {
                    ProgressView()
                        .padding(.top, 100)
                }
            }
            .padding()
        }
        .navigationTitle(friend.nickname)
        .onAppear { fetchFriendFortune() }
    }

    private func fetchFriendFortune() {
        guard let token = session.token else { return }
        Task {
            do {
                let response = try await APIClient.shared.request(
                    path: "/api/v1/fortune/today/friend/\(friend.friendUserId)",
                    token: token,
                    responseType: FortuneDetailResponse.self
                )
                DispatchQueue.main.async {
                    self.fortune = response
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "\(friend.nickname)님이 아직 오늘 운세를 확인하지 않았습니다."
                }
            }
        }
    }

    private func nudge() {
        guard let token = session.token else { return }
        Task {
            do {
                let _ = try await APIClient.shared.request(
                    path: "/api/v1/friends/nudge",
                    method: "POST",
                    token: token,
                    body: JSONEncoder().encode(["toUserId": friend.friendUserId]),
                    responseType: NudgeResponse.self
                )
            } catch {
                print("Nudge failed: \(error)")
            }
        }
    }
}
