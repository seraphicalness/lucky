import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var profile: ProfileResponse? = nil
    @State private var saju: SajuResponse? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showEditProfile = false
    @State private var isClaimingAdReward = false

    @State private var showContactSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                profileHeader
                sajuCard
                adRewardCard
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
        .confirmationDialog("개발자에게 문의하기", isPresented: $showContactSheet, titleVisibility: .visible) {
            Button("이메일로 문의하기") {
                let email = "support@harugiwun.com"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            }
            Button("개발자에게 커피 사주기 ☕️") {
                if let url = URL(string: "https://toss.me/harugiwun") {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) { }
        }
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
        HStack(alignment: .top) {
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
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "p.circle.fill")
                        .foregroundStyle(.yellow)
                    Text("\(session.points) P")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 사주팔자 컬러 카드

    private var sajuCard: some View {
        VStack(spacing: 14) {
            if let s = saju {
                // 시주 → 일주 → 월주 → 년주 순서로 표시
                let pillars: [PillarInfo?] = [s.timePillar, s.dayPillar, s.monthPillar, s.yearPillar]
                let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)

                // 라벨
                let titles = ["시주", "일주", "월주", "년주"]
                HStack {
                    ForEach(0..<4, id: \.self) { i in
                        Text(titles[i])
                            .font(.system(size: 11))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .frame(maxWidth: .infinity)
                    }
                }

                // 천간 (stems)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(0..<4, id: \.self) { i in
                        if let pillar = pillars[i] {
                            elementCircle(
                                hanja: stemHanja(from: pillar),
                                korean: pillar.stemKorean,
                                element: pillar.stemElement
                            )
                        } else {
                            emptyElementCircle()
                        }
                    }
                }
                // 지지 (branches)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(0..<4, id: \.self) { i in
                        if let pillar = pillars[i] {
                            elementCircle(
                                hanja: branchHanja(from: pillar),
                                korean: pillar.branchKorean,
                                element: pillar.branchElement
                            )
                        } else {
                            emptyElementCircle()
                        }
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

    @ViewBuilder
    private func emptyElementCircle() -> some View {
        Circle()
            .fill(Color(UIColor.systemGray5))
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
                showContactSheet = true
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

    // MARK: - 광고 보상 카드

    private var adRewardCard: some View {
        VStack(spacing: 0) {
            Button {
                Task {
                    await MainActor.run { isClaimingAdReward = true }
                    await session.claimAdReward()
                    await MainActor.run { isClaimingAdReward = false }
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(session.dailyAdCount >= 5 ? Color(UIColor.tertiaryLabel) : AppTheme.tabGreen)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("광고 보고 포인트 받기")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(UIColor.label))

                        Text("100P (오늘 \(session.dailyAdCount)/5)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }

                    Spacer()

                    if isClaimingAdReward {
                        ProgressView().tint(AppTheme.tabGreen)
                    } else {
                        Text("시청하기")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(session.dailyAdCount >= 5 ? Color(UIColor.tertiaryLabel) : AppTheme.tabGreen)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .disabled(session.dailyAdCount >= 5 || isClaimingAdReward)
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
    @State private var birthDate: Date
    @State private var isBirthTimeUnknown: Bool
    @State private var birthTime: Date
    @State private var gender: String?
    @State private var birthCalendarType: String
    @State private var birthIsLeapMonth: Bool
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    init(token: String, profile: ProfileResponse, onUpdated: @escaping (ProfileResponse) -> Void) {
        self.token = token
        self.profile = profile
        self.onUpdated = onUpdated
        _nickname = State(initialValue: profile.nickname)

        // 생일
        if let s = profile.birthDate, let d = Self.localDateFormatter.date(from: s) {
            _birthDate = State(initialValue: d)
        } else {
            _birthDate = State(initialValue: Date())
        }

        // 성별
        _gender = State(initialValue: profile.gender)

        // 양/음력 + 윤달
        _birthCalendarType = State(initialValue: profile.birthCalendarType ?? "SOLAR")
        _birthIsLeapMonth = State(initialValue: profile.birthIsLeapMonth ?? false)

        // 태어난 시각(선택)
        if let t = profile.birthTime, let parsed = Self.parseTime(t) {
            _isBirthTimeUnknown = State(initialValue: false)
            _birthTime = State(initialValue: parsed)
        } else {
            _isBirthTimeUnknown = State(initialValue: true)
            _birthTime = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("프로필")) {
                    TextField("이름", text: $nickname)
                        .autocorrectionDisabled()
                }

                Section(header: Text("양력/음력")) {
                    Picker("달력", selection: $birthCalendarType) {
                        Text("양력").tag("SOLAR")
                        Text("음력").tag("LUNAR")
                    }
                    .pickerStyle(.segmented)

                    if birthCalendarType == "LUNAR" {
                        Toggle("윤달", isOn: $birthIsLeapMonth)
                    } else {
                        // 양력일 때는 윤달 의미가 없으니 항상 false 유지
                        Toggle("윤달", isOn: Binding(get: { false }, set: { _ in birthIsLeapMonth = false }))
                            .disabled(true)
                            .opacity(0.5)
                    }
                }

                Section(header: Text("생년월일")) {
                    DatePicker("생일", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                Section(header: Text("태어난 시각")) {
                    Toggle("시간 모름", isOn: $isBirthTimeUnknown)
                    if !isBirthTimeUnknown {
                        DatePicker("시간", selection: $birthTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .frame(maxWidth: .infinity, minHeight: 140)
                    }
                }

                Section(header: Text("성별")) {
                    Picker("성별", selection: Binding(
                        get: { gender ?? "" },
                        set: { gender = $0.isEmpty ? nil : $0 }
                    )) {
                        Text("선택 안 함").tag("")
                        Text("남자").tag("MALE")
                        Text("여자").tag("FEMALE")
                    }
                    .pickerStyle(.segmented)
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
                    .disabled(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
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
        let trimmedName = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "이름을 입력해 주세요."
            return
        }
        isSaving = true
        do {
            let birthDateString = Self.localDateFormatter.string(from: birthDate)
            let birthTimeString: String? = isBirthTimeUnknown ? nil : Self.timeString(from: birthTime)
            let calendarTypeToSend = (birthCalendarType == "LUNAR") ? "LUNAR" : "SOLAR"
            let leapToSend = (calendarTypeToSend == "LUNAR") ? birthIsLeapMonth : false

            let req = ProfileUpdateRequest(
                nickname: trimmedName,
                birthDate: birthDateString,
                birthTime: birthTimeString,
                gender: gender,
                birthCalendarType: calendarTypeToSend,
                birthIsLeapMonth: leapToSend
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

// MARK: - EditProfileView Helpers

private extension EditProfileView {
    static let localDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func parseTime(_ s: String) -> Date? {
        // "HH:mm:ss" 또는 "HH:mm"
        let parts = s.split(separator: ":").map(String.init)
        guard parts.count >= 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
        var comps = DateComponents()
        comps.calendar = Calendar(identifier: .gregorian)
        comps.timeZone = TimeZone(secondsFromGMT: 0)
        comps.year = 2000
        comps.month = 1
        comps.day = 1
        comps.hour = h
        comps.minute = m
        comps.second = 0
        return comps.date
    }

    static func timeString(from date: Date) -> String {
        let cal = Calendar(identifier: .gregorian)
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        return String(format: "%02d:%02d:00", h, m)
    }
}
