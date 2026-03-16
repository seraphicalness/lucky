import SwiftUI

struct FortuneView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var fortune: FortuneDetailResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("오늘의 총점: \(fortune?.totalScore ?? 0)")
                        .font(.title2)
                        .bold()

                    categoryRow("재물", fortune?.moneyScore)
                    categoryRow("연애", fortune?.loveScore)
                    categoryRow("건강", fortune?.healthScore)
                    categoryRow("직장", fortune?.workScore)
                    categoryRow("인간관계", fortune?.socialScore)

                    Text(fortune?.summary ?? "운세를 불러오는 중입니다.")
                        .padding(.top, 8)

                    Text(fortune?.detailText ?? "")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("운세")
        .task {
            await loadFortune()
        }
    }

    private func loadFortune() async {
        guard let token = session.token else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            fortune = try await FortuneAPI.fetchToday(token: token)
        } catch {
            errorMessage = "운세를 불러오지 못했습니다."
            print("Fortune fetch error: \(error)")
        }
        isLoading = false
    }

    private func categoryRow(_ title: String, _ score: Int?) -> some View {
        HStack {
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
