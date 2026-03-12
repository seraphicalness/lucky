import SwiftUI

struct FortuneView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var fortune: FortuneDetailResponse? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private let categories: [(String, String, KeyPath<FortuneDetailResponse, Int>)] = [
        ("재물",   "dollarsign.circle.fill", \.moneyScore),
        ("연애",   "heart.circle.fill",      \.loveScore),
        ("건강",   "cross.case.circle.fill", \.healthScore),
        ("직장",   "briefcase.circle.fill",  \.workScore),
        ("인간관계", "person.2.circle.fill", \.socialScore),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                totalScoreCard
                categoriesCard
                detailCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("운세")
        .navigationBarTitleDisplayMode(.large)
        .task { await loadFortune() }
        .overlay {
            if isLoading { ProgressView() }
        }
        .alert("오류", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("확인") {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - 총점 카드

    private var totalScoreCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("오늘의 총점")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(UIColor.secondaryLabel))

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(fortune?.totalScore ?? 0)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(scoreColor(fortune?.totalScore ?? 0))
                    Text("점")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }

                Text(fortune?.summary ?? "")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .lineLimit(2)
            }

            Spacer()

            // 행운 정보
            VStack(spacing: 10) {
                luckyBadge(
                    icon: "sparkle",
                    label: "번호",
                    value: "\(fortune?.luckyNumber ?? 0)"
                )
                luckyBadge(
                    color: luckyColorValue(fortune?.luckyColor),
                    label: "색상",
                    value: fortune?.luckyColor ?? "-"
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 카테고리 카드

    private var categoriesCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(categories.enumerated()), id: \.offset) { idx, cat in
                let score = fortune.map { $0[keyPath: cat.2] } ?? 0
                categoryRow(icon: cat.1, title: cat.0, score: score)

                if idx < categories.count - 1 {
                    Divider().padding(.horizontal, 20)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func categoryRow(icon: String, title: String, score: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(scoreColor(score))
                .frame(width: 30)

            Text(title)
                .font(.system(size: 15))
                .frame(width: 56, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 8)
                    Capsule()
                        .fill(scoreColor(score))
                        .frame(width: geo.size.width * CGFloat(score) / 100, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(score)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(scoreColor(score))
                .frame(width: 32, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - 상세 카드

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("오늘의 상세 운세", systemImage: "doc.text")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(UIColor.secondaryLabel))

            Text(fortune?.detailText ?? "")
                .font(.system(size: 15))
                .foregroundStyle(Color(UIColor.label))
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 행운 배지

    private func luckyBadge(icon: String? = nil, color: Color? = nil, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.tabGreen)
            }
            if let color = color {
                Circle().fill(color).frame(width: 10, height: 10)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - API

    private func loadFortune() async {
        guard let token = session.token else { return }
        isLoading = true
        do {
            fortune = try await FortuneAPI.fetchToday(token: token)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Helpers

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return AppTheme.tabGreen }
        if score >= 60 { return Color(red: 0.95, green: 0.66, blue: 0.18) }
        return Color(red: 0.92, green: 0.35, blue: 0.35)
    }

    private func luckyColorValue(_ name: String?) -> Color {
        switch name {
        case "빨강", "Red":    return .red
        case "파랑", "Blue":   return .blue
        case "초록", "Green":  return AppTheme.tabGreen
        case "노랑", "Yellow": return .yellow
        case "보라", "Purple": return .purple
        case "주황", "Orange": return .orange
        default:               return .blue
        }
    }
}
