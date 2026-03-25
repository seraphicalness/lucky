import SwiftUI

struct FriendsView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var selectedTab: FriendsTab = .list
    @State private var friends: [FriendResponse] = []
    @State private var pendingRequests: [FriendRequestResponse] = []
    @State private var showSendRequest = false
    @State private var sendTargetId: String = ""
    @State private var alertMessage: String? = nil
    @State private var isLoadingAction = false

    enum FriendsTab { case list, requests }

    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            TabView(selection: $selectedTab) {
                friendListTab.tag(FriendsTab.list)
                requestsTab.tag(FriendsTab.requests)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("친구")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSendRequest = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .foregroundStyle(AppTheme.tabGreen)
                }
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

    // MARK: - 탭 피커

    private var tabPicker: some View {
        HStack(spacing: 0) {
            tabButton("친구 목록", tab: .list, badge: nil)
            tabButton("신청 관리", tab: .requests, badge: pendingRequests.isEmpty ? nil : pendingRequests.count)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemGroupedBackground))
    }

    private func tabButton(_ title: String, tab: FriendsTab, badge: Int?) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundStyle(selectedTab == tab ? AppTheme.tabGreen : Color(UIColor.secondaryLabel))
                if let badge = badge {
                    ZStack {
                        Circle().fill(Color.red).frame(width: 18, height: 18)
                        Text("\(badge)").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                if selectedTab == tab {
                    Rectangle()
                        .fill(AppTheme.tabGreen)
                        .frame(height: 2)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - 친구 목록 탭

    private var friendListTab: some View {
        Group {
            if friends.isEmpty {
                emptyView(
                    icon: "person.2",
                    title: "아직 친구가 없어요",
                    subtitle: "우측 상단 버튼으로 친구를 추가해보세요"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(friends) { friend in
                            friendRow(friend)
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
    }

    private func friendRow(_ friend: FriendResponse) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.tabGreen.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(String(friend.nickname.prefix(1)))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.tabGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(friend.nickname)
                    .font(.system(size: 16, weight: .medium))
                Text("친구 됨 · \(formattedDate(friend.friendSince))")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            if friend.id != friends.last?.id {
                Divider().padding(.leading, 78)
            }
        }
    }

    // MARK: - 신청 관리 탭

    private var requestsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !pendingRequests.isEmpty {
                    pendingRequestsSection
                } else {
                    emptyView(
                        icon: "bell",
                        title: "받은 신청이 없어요",
                        subtitle: "친구 신청이 오면 여기에 표시됩니다"
                    )
                    .frame(height: 200)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    private var pendingRequestsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("받은 친구 신청")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

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

    // MARK: - 빈 화면

    private func emptyView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color(UIColor.systemGray4))
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(UIColor.secondaryLabel))
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color(UIColor.tertiaryLabel))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - API

    private func loadData() async {
        guard let token = session.token else { return }
        async let friendsResult = FriendAPI.fetchFriends(token: token)
        async let requestsResult = FriendAPI.fetchPendingRequests(token: token)
        friends = (try? await friendsResult) ?? []
        pendingRequests = (try? await requestsResult) ?? []
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
