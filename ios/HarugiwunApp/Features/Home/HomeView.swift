import SwiftUI
import Foundation
import WidgetKit

struct HomeView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var fortune: FortuneDetailResponse? = nil
    @State private var tarotCard: TarotCardResponse? = nil
    @State private var showTarotPick = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showWidgetGuide = false
    @State private var messageIndex = 0

    private let mascotMessages: [String] = [
        "오늘도 행운 가득한 하루 되세요",
        "마음이 가는 대로 움직여 볼까요?",
        "작은 선택이 큰 행운을 부를지도 몰라요",
        "오늘은 나를 조금 더 믿어주는 날로!",
        "기대하지 않은 곳에서 좋은 소식이 올지도요",
        "편안한 마음이 좋은 흐름을 데려와요",
        "하고 싶은 일이 있다면 살짝 시작해봐요",
        "쉬어가는 것도 행운을 쌓는 시간이래요",
        "오늘 하루, 스스로에게 조금 더 친절하게",
        "괜찮아요, 천천히 가도 우리는 결국 도착해요"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                mascotSection
                if isLoading {
                    ProgressView().padding(.top, 40)
                } else {
                    fortuneCard
                }

                tarotCardView

                widgetButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: StoreView()) {
                    HStack(spacing: 4) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(UIColor.label))
                        Text("상점")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(UIColor.label))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
        }
        .task { 
            await loadFortune()
            await session.fetchBalance()
        }
        .sheet(isPresented: $showWidgetGuide) {
            WidgetGuideSheet()
        }
        .fullScreenCover(isPresented: $showTarotPick) {
            if let token = session.token {
                TarotPickView(token: token) { picked in
                    self.tarotCard = picked
                    self.showTarotPick = false
                }
            }
        }
        .alert("오류", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("확인") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - 마스코트 섹션

    private var mascotSection: some View {
        ZStack(alignment: .topLeading) {
            // 캐릭터: 우측 상단 배치
            HStack {
                Spacer()
                Image("Mascot")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 170)
                    .padding(.top, 6)
            }

            // 날짜 + 말풍선: 좌측 상단 배치
            VStack(alignment: .leading, spacing: 10) {
                Text(todayString())
                    .font(.system(size: 13))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .padding(.top, 24)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        guard !mascotMessages.isEmpty else { return }
                        var next = Int.random(in: 0..<mascotMessages.count)
                        if next == messageIndex && mascotMessages.count > 1 {
                            next = (next + 1) % mascotMessages.count
                        }
                        messageIndex = next
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(mascotMessages[messageIndex])
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                            )
                            .overlay(alignment: .topLeading) {
                                BubbleTail()
                                    .fill(Color.white)
                                    .frame(width: 18, height: 9)
                                    .rotationEffect(.degrees(180))
                                    .offset(x: 22, y: 34)
                            }
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: 240, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .padding(.bottom, 10)
    }

    // MARK: - 운세 카드

    private var fortuneCard: some View {
        VStack(spacing: 0) {
            // 총점
            VStack(spacing: 4) {
                Text("오늘의 운세")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .padding(.top, 20)

                Text("\(fortune?.totalScore ?? 0)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(scoreColor(fortune?.totalScore ?? 0))

                Text("점")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .padding(.bottom, 4)
            }

            Divider().padding(.horizontal, 20)

            // 요약
            Text(fortune?.summary ?? "")
                .font(.system(size: 14))
                .foregroundStyle(Color(UIColor.label))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            Divider().padding(.horizontal, 20)

            // 행운 색상 / 번호
            HStack {
                luckyItem(
                    title: "행운 색상",
                    value: fortune?.luckyColor ?? "-",
                    icon: Circle()
                        .fill(luckyColorValue(fortune?.luckyColor))
                        .frame(width: 14, height: 14)
                )
                Divider().frame(height: 36)
                luckyItem(
                    title: "행운 번호",
                    value: "\(fortune?.luckyNumber ?? 0)",
                    icon: Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.tabGreen)
                )
            }
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 오늘의 타로 카드

    private var tarotCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.tabGreen)
                Text("오늘의 타로 카드")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                Spacer()
            }

            if let tarotCard {
                if tarotCard.picked {
                    HStack(alignment: .top, spacing: 14) {
                        tarotImage(imageUrl: tarotCard.imageUrl)
                            .frame(width: 92, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(tarotCard.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(UIColor.label))

                            Text(tarotCard.meaning)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.tabGreen)

                            Text(tarotCard.description)
                                .font(.system(size: 12))
                                .foregroundStyle(Color(UIColor.label))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    // 뽑기 전 상태
                    Button {
                        showTarotPick = true
                    } label: {
                        VStack(spacing: 6) {
                            Text("오늘의 행운 카드")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(UIColor.label))
                            Text("오늘의 행운 카드")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 92, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Text("타로 카드를 불러오는 중입니다.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.top, 14)
    }

    @ViewBuilder
    private func tarotImage(imageUrl: String) -> some View {
        let fullURL = URL(string: imageUrl, relativeTo: APIClient.shared.baseURL)?.absoluteURL

        if let fullURL {
            AsyncImage(url: fullURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    placeholderTarotImage
                case .empty:
                    placeholderTarotImage
                @unknown default:
                    placeholderTarotImage
                }
            }
        } else {
            placeholderTarotImage
        }
    }

    private var placeholderTarotImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.systemGray5))
            Image(systemName: "moon.stars")
                .font(.system(size: 22))
                .foregroundStyle(Color(UIColor.tertiaryLabel))
        }
    }

    private func luckyItem<Icon: View>(title: String, value: String, icon: Icon) -> some View {
        HStack(spacing: 6) {
            icon
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 위젯 편집 버튼

    private var widgetButton: some View {
        Button {
            showWidgetGuide = true
        } label: {
            HStack {
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 15))
                Text("위젯 편집하기")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .foregroundStyle(AppTheme.tabGreen)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.top, 14)
    }

    // MARK: - API

    private func loadFortune() async {
        guard let token = session.token else { return }
        isLoading = true
        do {
            // 앱에서 사용할 상세 운세
            fortune = try await FortuneAPI.fetchToday(token: token)

            // 위젯용 요약 운세 저장 + 위젯 새로고침
            let widgetFortune = try await FortuneAPI.fetchWidget(token: token)
            SharedStore.saveWidgetFortune(widgetFortune)
            WidgetCenter.shared.reloadAllTimelines()

            // 오늘의 타로 카드 (운세 카드와 별개로, 실패해도 홈은 유지)
            tarotCard = try? await FortuneAPI.fetchTodayTarot(token: token)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers

    private func todayString() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일 EEEE"
        return f.string(from: Date())
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return AppTheme.tabGreen }
        if score >= 60 { return Color(red: 0.95, green: 0.66, blue: 0.18) }
        return Color(red: 0.92, green: 0.35, blue: 0.35)
    }

    private func luckyColorValue(_ name: String?) -> Color {
        switch name {
        case "빨강", "Red":   return .red
        case "파랑", "Blue":  return .blue
        case "초록", "Green": return AppTheme.tabGreen
        case "노랑", "Yellow": return .yellow
        case "보라", "Purple": return .purple
        case "주황", "Orange": return .orange
        case "흰색", "White":  return Color(UIColor.systemGray4)
        case "검정", "Black":  return .black
        default:              return .blue
        }
    }
}

// MARK: - 말풍선 꼬리

private struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - 포인트 상점 (임시)

private struct StoreView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        VStack(spacing: 16) {
            Text("포인트 상점")
                .font(.title2.bold())

            Text("현재 \(session.points)P")
                .foregroundStyle(.secondary)

            Text("준비중이에요.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Tarot Pick View (Full Screen)

private struct TarotPickView: View {
    let token: String
    let onPicked: (TarotCardResponse) -> Void

    @Environment(\.dismiss) private var dismiss
    @Namespace private var ns

    @State private var selectedIndex: Int? = nil
    @State private var flipRotation: Double = 0
    @State private var result: TarotCardResponse? = nil
    @State private var isPicking = false
    @State private var errorMessage: String? = nil

    private let cardCount = 9

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.10),
                    Color(red: 0.08, green: 0.10, blue: 0.16),
                    Color(red: 0.04, green: 0.04, blue: 0.07),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Text("오늘의 타로를 뽑아보세요")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 10)

                Text("카드를 하나 선택하면 오늘 하루 동안 고정돼요")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .padding(.top, 6)
                    .padding(.bottom, 18)

                GeometryReader { geo in
                    ZStack {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3),
                            spacing: 14
                        ) {
                            ForEach(0..<cardCount, id: \.self) { idx in
                                if selectedIndex == idx {
                                    Color.clear
                                        .frame(height: 150)
                                } else {
                                    backCard
                                        .matchedGeometryEffect(id: idx, in: ns)
                                        .frame(height: 150)
                                        .onTapGesture { pick(index: idx) }
                                }
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 10)

                        if let selectedIndex {
                            flipCardView
                                .matchedGeometryEffect(id: selectedIndex, in: ns)
                                .frame(width: min(geo.size.width * 0.62, 260), height: 360)
                                .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 14)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }

                Spacer(minLength: 0)

                if let result, flipRotation >= 180 {
                    Button {
                        onPicked(result)
                        dismiss()
                    } label: {
                        Text("운세 확인하기")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppTheme.tabGreen)
                            .clipShape(Capsule())
                            .padding(.horizontal, 20)
                            .padding(.bottom, 26)
                    }
                } else {
                    Text(isPicking ? "카드를 해석하는 중..." : " ")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.65))
                        .frame(height: 54)
                        .padding(.bottom, 26)
                }
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

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .padding(12)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var backCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.18),
                            Color(red: 0.08, green: 0.09, blue: 0.14),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.tabGreen.opacity(0.9))
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 42, height: 6)
            }
        }
    }

    private var flipCardView: some View {
        let showingFront = flipRotation >= 90

        return ZStack {
            if showingFront {
                frontCard(result: result)
            } else {
                backCard
            }
        }
        .rotation3DEffect(.degrees(flipRotation), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.9), value: flipRotation)
    }

    private func frontCard(result: TarotCardResponse?) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(spacing: 10) {
                if let result {
                    AsyncImage(url: URL(string: result.imageUrl, relativeTo: APIClient.shared.baseURL)?.absoluteURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.10))
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 26))
                                        .foregroundStyle(Color.white.opacity(0.7))
                                )
                        }
                    }
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text(result.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(result.meaning)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.tabGreen)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                } else {
                    ProgressView().tint(.white)
                    Text("카드를 불러오는 중...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
            }
            .padding(16)
        }
    }

    private func pick(index: Int) {
        guard selectedIndex == nil, !isPicking else { return }
        selectedIndex = index
        isPicking = true
        flipRotation = 0
        result = nil

        Task {
            do {
                async let api: TarotCardResponse = FortuneAPI.pickTodayTarot(token: token)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.9)) {
                        flipRotation = 180
                    }
                }
                let picked = try await api
                await MainActor.run {
                    self.result = picked
                    self.isPicking = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
                    self.isPicking = false
                    self.selectedIndex = nil
                    self.flipRotation = 0
                }
            }
        }
    }
}

// MARK: - 위젯 안내 시트

struct WidgetGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let steps: [(String, String)] = [
        ("1", "홈 화면을 길게 눌러 편집 모드로 진입하세요."),
        ("2", "왼쪽 상단 '+' 버튼을 탭하세요."),
        ("3", "'하루긔운'을 검색하세요."),
        ("4", "원하는 위젯 크기를 선택하고 '위젯 추가'를 탭하세요."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(UIColor.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            Image("Mascot")
                .resizable()
                .scaledToFit()
                .frame(height: 100)

            Text("위젯 추가하기")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 8)

            Text("홈 화면에서 오늘의 운세를 바로 확인하세요")
                .font(.system(size: 14))
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .padding(.top, 4)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                ForEach(steps, id: \.0) { step in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.tabGreen)
                                .frame(width: 26, height: 26)
                            Text(step.0)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text(step.1)
                            .font(.system(size: 15))
                            .foregroundStyle(Color(UIColor.label))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)

                    if step.0 != "4" {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)

            Button {
                WidgetCenter.shared.reloadAllTimelines()
                dismiss()
            } label: {
                Text("위젯 새로고침")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppTheme.tabGreen)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
