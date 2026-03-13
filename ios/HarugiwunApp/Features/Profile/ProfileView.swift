import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var profile: ProfileResponse? = nil
    @State private var saju: SajuResponse? = nil

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
        .task { loadMockData() }
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
                    Text("\(s.dayPillarName)일주 \(genderLabel)")
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
                let pillars: [PillarInfo?] = [s.yearPillar, s.monthPillar, s.dayPillar, s.timePillar]
                let validPillars = pillars.compactMap { $0 }
                let columns = Array(
                    repeating: GridItem(.flexible(), spacing: 14),
                    count: validPillars.count
                )

                // 천간 (stems)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(validPillars.indices, id: \.self) { i in
                        elementCircle(validPillars[i].stemElement)
                    }
                }
                // 지지 (branches)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(validPillars.indices, id: \.self) { i in
                        elementCircle(validPillars[i].branchElement)
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
    private func elementCircle(_ element: String) -> some View {
        Circle()
            .fill(color(for: element))
            .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - 설정 메뉴 카드

    private var settingsCard: some View {
        VStack(spacing: 0) {
            menuRow(icon: "person.crop.circle", label: "정보 수정하기") {
                // TODO: 정보 수정 화면 이동
            }
            menuDivider
            menuRow(icon: "megaphone", label: "알림 설정") {
                // TODO: 알림 설정
            }
            menuDivider
            menuRow(icon: "questionmark.circle", label: "개발자에게 문의하기") {
                let email = "support@harugiwun.com"
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            }
            menuDivider
            menuRow(icon: "cup.and.saucer", label: "개발자에게 커피 사주기") {
                // TODO: 실제 결제 연동 (App Store IAP 등)
                // 임시로 토스나 카카오페이 등 결제 링크가 있다면 연결 가능
                if let url = URL(string: "https://toss.me/harugiwun") {
                    UIApplication.shared.open(url)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 로그아웃 카드

    private var logoutCard: some View {
        menuRow(icon: "rectangle.portrait.and.arrow.right", label: "로그아웃") {
            session.token = nil
            session.userId = nil
            session.needsOnboarding = false
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

    // MARK: - Mock 데이터 (API 연동 전)

    private func loadMockData() {
        profile = ProfileResponse(
            userId: 1,
            nickname: "김나희",
            birthDate: "2000-01-01",
            birthTime: "12:12:00",
            gender: "FEMALE",
            birthCalendarType: "SOLAR",
            birthIsLeapMonth: false
        )
        saju = SajuResponse(
            yearPillar:  PillarInfo(characters: "경진", stemKorean: "경", branchKorean: "진", stemElement: "금", branchElement: "토"),
            monthPillar: PillarInfo(characters: "무인", stemKorean: "무", branchKorean: "인", stemElement: "목", branchElement: "목"),
            dayPillar:   PillarInfo(characters: "신축", stemKorean: "신", branchKorean: "축", stemElement: "목", branchElement: "토"),
            timePillar:  PillarInfo(characters: "임오", stemKorean: "임", branchKorean: "오", stemElement: "수", branchElement: "수"),
            dayMasterKorean: "신",
            dayMasterElement: "금",
            dayPillarName: "신축",
            dayMasterStrength: "신약",
            elementDistribution: ["목": 3, "화": 0, "토": 2, "금": 2, "수": 1],
            yongsin: "화"
        )
    }
}
