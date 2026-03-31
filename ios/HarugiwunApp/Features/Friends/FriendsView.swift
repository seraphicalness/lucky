import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var session: SessionStore

    /// 임시 목업 — 서버 친구가 없을 때만 사용. 배포 전 `false`로 끄기.
    private static let useTemporaryMockFriends = true

    private static let temporaryMockFriends: [FriendResponse] = [
        FriendResponse(friendUserId: 9001, nickname: "친구1", friendSince: "2026-01-15T10:00:00", lastActiveAt: nil),
        FriendResponse(friendUserId: 9002, nickname: "친구2", friendSince: "2026-02-01T10:00:00", lastActiveAt: nil),
        FriendResponse(friendUserId: 9003, nickname: "친구3", friendSince: "2026-02-20T10:00:00", lastActiveAt: nil),
        FriendResponse(friendUserId: 9004, nickname: "친구4", friendSince: "2026-03-01T10:00:00", lastActiveAt: nil)
    ]

    @State private var friends: [FriendResponse] = []
    @State private var pendingRequests: [FriendRequestResponse] = []
    /// 0 = 나, 1... = friends[index - 1]
    @State private var selectedCircleIndex: Int = 0
    @State private var didSetInitialFriendSelection = false

    @State private var showSendRequest = false
    @State private var showRequestsSheet = false
    @State private var sendTargetId: String = ""
    @State private var alertMessage: String? = nil
    @State private var isLoadingAction = false
    @State private var isNudging = false

    /// 공감 이모지(고정 8종) — 받은 횟수 많은 순으로 모달에 정렬
    private static let reactionPalette: [String] = ["😝", "😥", "👍", "👌", "😭", "💩", "💖", "💢"]

    @State private var reactionCounts: [String: Int] = [
        "😝": 0, "😥": 0, "👍": 0, "👌": 0,
        "😭": 0, "💩": 0, "💖": 0, "💢": 0
    ]
    @State private var showReactionPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                horizontalFriendStrip
                    .padding(.top, 4)

                if friends.isEmpty {
                    emptyFriendsPlaceholder
                        .padding(.top, 28)
                } else if selectedCircleIndex == 0 {
                    meSelectedSection
                        .padding(.top, 20)
                } else if let friend = selectedFriend {
                    friendDetailSection(friend)
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("친구")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showRequestsSheet = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(UIColor.label))
                        if !pendingRequests.isEmpty {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 7, height: 7)
                                .offset(x: 3, y: -2)
                        }
                    }
                }
                .accessibilityLabel("받은 친구 신청")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSendRequest = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(UIColor.label))
                }
                .accessibilityLabel("친구 추가")
            }
        }
        .sheet(isPresented: $showSendRequest) {
            SendFriendRequestSheet(
                targetId: $sendTargetId,
                myUserId: session.userId,
                onSend: { id in
                    sendFriendRequest(toUserId: id)
                    showSendRequest = false
                }
            )
        }
        .sheet(isPresented: $showRequestsSheet) {
            pendingRequestsSheet
        }
        .sheet(isPresented: $showReactionPicker) {
            reactionPickerSheet
        }
        .alert("알림", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("확인") { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .task { await loadData() }
    }

    // MARK: - 가로 친구 스트립 (나 + 친구들)

    private var horizontalFriendStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                circleAvatar(label: "나", index: 0)
                ForEach(Array(friends.enumerated()), id: \.element.id) { i, friend in
                    circleAvatar(label: friend.nickname, index: i + 1)
                }
            }
            .padding(.vertical, 10)
            .padding(.trailing, 8)
        }
    }

    private func circleAvatar(label: String, index: Int) -> some View {
        let isSelected = selectedCircleIndex == index
        return Button {
            selectedCircleIndex = index
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 58, height: 58)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? AppTheme.tabGreen : Color(UIColor.systemGray4), lineWidth: isSelected ? 2.5 : 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)

                    Text(String(label.prefix(1)))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }

                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .lineLimit(1)
                    .frame(width: 68)
            }
        }
        .buttonStyle(.plain)
    }

    private var selectedFriend: FriendResponse? {
        guard selectedCircleIndex > 0 else { return nil }
        let i = selectedCircleIndex - 1
        guard i < friends.count else { return nil }
        return friends[i]
    }

    // MARK: - 나 선택

    private var meSelectedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 운세는 홈 탭에서 확인할 수 있어요.")
                .font(.system(size: 15))
                .foregroundStyle(Color(UIColor.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 친구 선택 (목업 카드 + 공감)

    private func friendDetailSection(_ friend: FriendResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .overlay {
                        Text(String(friend.nickname.prefix(1)))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AppTheme.tabGreen)
                    }

                Text(friend.nickname)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(UIColor.label))

                Spacer(minLength: 8)

                Button {
                    Task { await nudgeFriend(friend) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: 14))
                        Text("콕 찌르기")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color(UIColor.label))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .disabled(isNudging)
            }

            VStack(spacing: 12) {
                Text("아직 운세를 확인하지 않았어요")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(UIColor.label))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

                Button {
                    Task {
                        await session.claimAdReward()
                        alertMessage = "광고 보상을 적용했어요. 운세 비교는 곧 연동될 예정이에요."
                    }
                } label: {
                    Text("광고보고 친구와 운세 비교하기")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(UIColor.label))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }

            reactionBar
        }
    }

    private var reactionBar: some View {
        HStack {
            Spacer()
            Button {
                showReactionPicker = true
            } label: {
                HStack(spacing: 8) {
                    Text("공감하기")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "face.smiling")
                        .font(.system(size: 15))
                }
                .foregroundStyle(Color(UIColor.label))
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    private var sortedReactionItems: [(emoji: String, count: Int)] {
        Self.reactionPalette.map { emoji in
            (emoji: emoji, count: reactionCounts[emoji, default: 0])
        }
        .sorted { a, b in
            if a.count != b.count { return a.count > b.count }
            let ia = Self.reactionPalette.firstIndex(of: a.emoji) ?? 0
            let ib = Self.reactionPalette.firstIndex(of: b.emoji) ?? 0
            return ia < ib
        }
    }

    private var reactionPickerSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                    spacing: 14
                ) {
                    ForEach(sortedReactionItems, id: \.emoji) { item in
                        Button {
                            reactionCounts[item.emoji, default: 0] += 1
                            showReactionPicker = false
                        } label: {
                            VStack(spacing: 8) {
                                Text(item.emoji)
                                    .font(.system(size: 38))
                                Text("\(item.count)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.systemGray6).opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                Spacer(minLength: 8)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("공감하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { showReactionPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - 빈 상태

    private var emptyFriendsPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.2")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color(UIColor.systemGray3))
            Text("관심 친구를 추가해주세요.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(UIColor.secondaryLabel))
            Text("우측 상단에서 친구 신청을 보낼 수 있어요.")
                .font(.system(size: 13))
                .foregroundStyle(Color(UIColor.tertiaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 받은 신청 시트

    private var pendingRequestsSheet: some View {
        NavigationStack {
            Group {
                if pendingRequests.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "bell.slash")
                            .font(.system(size: 36))
                            .foregroundStyle(Color(UIColor.systemGray3))
                        Text("받은 신청이 없어요")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(pendingRequests) { req in
                                requestRow(req)
                                if req.id != pendingRequests.last?.id {
                                    Divider().padding(.leading, 78)
                                }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("받은 친구 신청")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { showRequestsSheet = false }
                }
            }
        }
    }

    private func requestRow(_ req: FriendRequestResponse) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 44, height: 44)
                Text(String(req.fromUserNickname.prefix(1)))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(req.fromUserNickname)
                    .font(.system(size: 16, weight: .medium))
                Text(formattedDate(req.createdAt))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    respondToRequest(req.requestId, action: "REJECTED")
                } label: {
                    Text("거절")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.systemGray5))
                        .clipShape(Capsule())
                }

                Button {
                    respondToRequest(req.requestId, action: "ACCEPTED")
                } label: {
                    Text("수락")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.tabGreen)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - API

    private func loadData() async {
        guard let token = session.token else { return }
        async let friendsResult = FriendAPI.fetchFriends(token: token)
        async let requestsResult = FriendAPI.fetchPendingRequests(token: token)
        let loadedFriends = (try? await friendsResult) ?? []
        let loadedReq = (try? await requestsResult) ?? []
        let mergedFriends: [FriendResponse] = {
            if Self.useTemporaryMockFriends && loadedFriends.isEmpty {
                return Self.temporaryMockFriends
            }
            return loadedFriends
        }()
        await MainActor.run {
            friends = mergedFriends
            pendingRequests = loadedReq
            if !didSetInitialFriendSelection, !friends.isEmpty {
                selectedCircleIndex = 1
                didSetInitialFriendSelection = true
            }
            if selectedCircleIndex > friends.count {
                selectedCircleIndex = friends.isEmpty ? 0 : 1
            }
        }
    }

    private func nudgeFriend(_ friend: FriendResponse) async {
        if Self.useTemporaryMockFriends,
           Self.temporaryMockFriends.contains(where: { $0.friendUserId == friend.friendUserId }) {
            await MainActor.run {
                alertMessage = "임시 친구입니다. 실제 콕 찌르기는 서버에 친구가 등록된 뒤에 할 수 있어요."
            }
            return
        }
        guard let token = session.token else { return }
        isNudging = true
        defer { isNudging = false }
        do {
            let res = try await FriendAPI.nudge(token: token, toUserId: friend.friendUserId)
            await MainActor.run { alertMessage = res.message }
        } catch {
            await MainActor.run {
                alertMessage = (error as? APIError)?.errorDescription ?? "콕 찌르기에 실패했어요."
            }
        }
    }

    private func sendFriendRequest(toUserId: Int) {
        guard let token = session.token, !isLoadingAction else { return }
        isLoadingAction = true
        Task {
            do {
                _ = try await FriendAPI.sendRequest(token: token, toUserId: toUserId)
                await MainActor.run { alertMessage = "친구 신청을 보냈어요!" }
            } catch {
                await MainActor.run { alertMessage = (error as? APIError)?.errorDescription ?? "친구 신청에 실패했어요." }
            }
            await MainActor.run { isLoadingAction = false }
        }
    }

    private func respondToRequest(_ requestId: Int, action: String) {
        guard let token = session.token, !isLoadingAction else { return }
        isLoadingAction = true
        Task {
            do {
                _ = try await FriendAPI.respondRequest(token: token, requestId: requestId, action: action)
                await MainActor.run {
                    withAnimation { pendingRequests.removeAll { $0.requestId == requestId } }
                    if action == "ACCEPTED" {
                        alertMessage = "친구 요청을 수락했어요!"
                        Task { await loadData() }
                    }
                }
            } catch {
                await MainActor.run { alertMessage = (error as? APIError)?.errorDescription ?? "처리에 실패했어요." }
            }
            await MainActor.run { isLoadingAction = false }
        }
    }

    // MARK: - Helpers

    private func formattedDate(_ str: String) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let iso2 = ISO8601DateFormatter()

        let date = iso.date(from: str) ?? iso2.date(from: str)
        guard let date else {
            return String(str.prefix(10)).replacingOccurrences(of: "-", with: ".")
        }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
}

// MARK: - 친구 신청 시트

struct SendFriendRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var targetId: String
    let myUserId: Int?
    let onSend: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(UIColor.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 24)

            Text("친구 신청")
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 6)

            VStack(spacing: 4) {
                Text("상대방의 유저 ID를 입력해 주세요")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                if let myUserId {
                    Text("내 유저 ID: \(myUserId)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
            .padding(.bottom, 28)

            VStack(alignment: .leading, spacing: 8) {
                Text("유저 ID")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 24)

                HStack {
                    TextField("숫자로 입력", text: $targetId)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16))
                    if !targetId.isEmpty {
                        Button { targetId = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(UIColor.systemGray3))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(UIColor.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
            }

            Spacer()

            Button {
                if let id = Int(targetId) {
                    onSend(id)
                }
            } label: {
                Text("신청하기")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Int(targetId) != nil ? AppTheme.tabGreen : Color(UIColor.systemGray4))
                    .clipShape(Capsule())
            }
            .disabled(Int(targetId) == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}
