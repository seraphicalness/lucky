import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var profile: ProfileResponse? = nil
    @State private var saju: SajuResponse? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showEditProfile = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileHeader
                sajuCard
                settingsCard
                logoutCard

                HStack {
                    Spacer()
                    Button("회원 탈퇴") { }
                        .font(.system(size: 12))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await loadData() }
        .overlay { if isLoading { ProgressView() } }
        .alert("오류", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("확인") {}
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showEditProfile) {
            if let profile, let token = session.token {
                EditProfileView(token: token, profile: profile) { updated in
                    self.profile = updated
                }
            }
        }
    }

    // MARK: - 프로필 헤더

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(profile?.nickname ?? "-")
                .font(.system(size: 22, weight: .bold))

            if let p = profile, let dateStr = p.birthDate {
                Text(birthInfoString(dateStr, time: p.birthTime))
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }

            if let s = saju, let p = profile {
                let genderLabel = p.gender == "MALE" ? "남자" : p.gender == "FEMALE" ? "여자" : ""
                Text("\(s.dayPillarName) \(genderLabel)")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 사주팔자 컬러 카드

    private var sajuCard: some View {
        VStack(spacing: 14) {
            if let s = saju {
                let pillars: [PillarInfo?] = [s.yearPillar, s.monthPillar, s.dayPillar, s.timePillar]
                let validPillars = pillars.compactMap { $0 }
                let columns = Array(
                    repeating: GridItem(.flexible(), spacing: 14),
                    count: validPillars.count
                )

                // 연 · 월 · 일 · 시 라벨
                let titles = ["연주", "월주", "일주", "시주"]
                HStack {
                    ForEach(0..<validPillars.count, id: \.self) { i in
                        Text(titles[i])
                            .font(.system(size: 11))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .frame(maxWidth: .infinity)
                    }
                }

                // 천간 (stems)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(validPillars.indices, id: \.self) { i in
                        elementCircle(
                            hanja: stemHanja(from: validPillars[i]),
                            korean: validPillars[i].stemKorean,
                            element: validPillars[i].stemElement
                        )
                    }
                }
                // 지지 (branches)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(validPillars.indices, id: \.self) { i in
                        elementCircle(
                            hanja: branchHanja(from: validPillars[i]),
                            korean: validPillars[i].branchKorean,
                            element: validPillars[i].branchElement
                        )
                    }
                }
            } else {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)
                ForEach(0..<2, id: \.self) { _ in
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(0..<4, id: \.self) { _ in
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func elementCircle(hanja: String, korean: String, element: String) -> some View {
        ZStack {
            Circle()
                .fill(color(for: element))
            VStack(spacing: 2) {
                Text(hanja)
                    .font(.system(size: 16, weight: .semibold))
                Text(korean)
                    .font(.system(size: 11))
            }
            .foregroundStyle(.white)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - 설정 메뉴 카드

    private var settingsCard: some View {
        VStack(spacing: 0) {
            menuRow(icon: "person.crop.circle", label: "정보 수정하기") {
                showEditProfile = true
            }
            menuDivider
            menuRow(icon: "megaphone", label: "알림 설정") {
                // TODO: 알림 설정
            }
            menuDivider
            menuRow(icon: "questionmark.circle", label: "개발자에게 문의하기") {
                // TODO: 문의하기
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 로그아웃 카드

    private var logoutCard: some View {
        menuRow(icon: "rectangle.portrait.and.arrow.right", label: "로그아웃") {
            session.logout()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 공통 컴포넌트

    private func menuRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(UIColor.label))
                    .frame(width: 22)
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(UIColor.label))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
    }

    private var menuDivider: some View {
        Divider().padding(.leading, 56)
    }

    // MARK: - 오행 색상

    private func color(for element: String) -> Color {
        switch element {
        case "목": return Color(red: 0.27, green: 0.82, blue: 0.41)   // 초록
        case "화": return Color(red: 0.92, green: 0.25, blue: 0.27)   // 빨강
        case "토": return Color(red: 0.95, green: 0.66, blue: 0.18)   // 황토
        case "금": return Color(red: 0.73, green: 0.73, blue: 0.73)   // 회색
        case "수": return Color(red: 0.27, green: 0.53, blue: 0.90)   // 파랑
        default:   return Color(UIColor.systemGray4)
        }
    }

    // MARK: - 한자 분리

    private func stemHanja(from pillar: PillarInfo) -> String {
        let chars = Array(pillar.characters)
        guard !chars.isEmpty else { return "" }
        return String(chars[0])
    }

    private func branchHanja(from pillar: PillarInfo) -> String {
        let chars = Array(pillar.characters)
        guard chars.count >= 2 else { return "" }
        return String(chars[1])
    }

    // MARK: - 날짜 포맷

    private func birthInfoString(_ dateStr: String, time: String?) -> String {
        let dp = dateStr.split(separator: "-")
        guard dp.count == 3 else { return dateStr }
        let y = dp[0], m = Int(dp[1]) ?? 0, d = Int(dp[2]) ?? 0

        if let t = time {
            let tp = t.split(separator: ":")
            if tp.count >= 2, let h = Int(tp[0]), let min = Int(tp[1]) {
                return "\(y)년 \(m)월 \(d)일 \(h)시 \(min)분생"
            }
        }
        return "\(y)년 \(m)월 \(d)일생"
    }

    // MARK: - API

    private func loadData() async {
        guard let token = session.token else { return }
        isLoading = true
        do {
            async let profileResult = ProfileAPI.fetchProfile(token: token)
            async let sajuResult = ProfileAPI.fetchSaju(token: token)
            profile = try await profileResult
            saju = try? await sajuResult  // 사주 실패해도 프로필은 표시
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Edit Profile

private struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    let token: String
    let profile: ProfileResponse
    let onUpdated: (ProfileResponse) -> Void

    @State private var nickname: String
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    init(token: String, profile: ProfileResponse, onUpdated: @escaping (ProfileResponse) -> Void) {
        self.token = token
        self.profile = profile
        self.onUpdated = onUpdated
        _nickname = State(initialValue: profile.nickname)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("프로필")) {
                    TextField("이름", text: $nickname)
                        .autocorrectionDisabled()
                }
                if let id = profile.userId as Int? {
                    Section(header: Text("내 유저 ID")) {
                        Text("\(id)")
                            .font(.system(size: 15, weight: .medium))
                    }
                }
            }
            .navigationTitle("정보 수정하기")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("저장")
                        }
                    }
                    .disabled(nickname.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .alert("오류", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("확인") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func save() async {
        guard let birthDate = profile.birthDate else {
            errorMessage = "생년월일 정보가 없어 수정할 수 없어요."
            return
        }
        isSaving = true
        do {
            let req = ProfileUpdateRequest(
                nickname: nickname,
                birthDate: birthDate,
                birthTime: profile.birthTime,
                gender: profile.gender,
                birthCalendarType: profile.birthCalendarType,
                birthIsLeapMonth: profile.birthIsLeapMonth
            )
            let updated = try await ProfileAPI.updateProfile(token: token, request: req)
            await MainActor.run {
                onUpdated(updated)
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
                isSaving = false
            }
        }
    }
}
