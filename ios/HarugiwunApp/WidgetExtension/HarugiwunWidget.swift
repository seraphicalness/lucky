import SwiftUI
import WidgetKit

// MARK: - Shared 모델 (위젯용 요약 운세)

private struct WidgetFortune: Codable {
    let date: String
    let pending: Bool
    let pendingMessage: String?
    let totalScore: Int?
    let luckyColor: String?
    let luckyNumber: Int?
    let summary: String?
}

// MARK: - Entry

struct HarugiwunEntry: TimelineEntry {
    let date: Date
    let totalScore: Int
    let luckyColorName: String
    let luckyNumber: Int
    let summary: String
}

// MARK: - Provider

struct HarugiwunProvider: TimelineProvider {
    private let appGroupID = "group.com.example.harugiwun"

    func placeholder(in context: Context) -> HarugiwunEntry {
        HarugiwunEntry(
            date: Date(),
            totalScore: 78,
            luckyColorName: "파랑",
            luckyNumber: 7,
            summary: "기분 좋은 흐름이 이어지는 날이에요."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HarugiwunEntry) -> Void) {
        completion(loadFromShared() ?? placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HarugiwunEntry>) -> Void) {
        let entry = loadFromShared() ?? placeholder(in: context)
        // 15분 후에 한 번 더 갱신 요청
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(next))
        completion(timeline)
    }

    private func loadFromShared() -> HarugiwunEntry? {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: "widget_fortune"),
            let fortune = try? JSONDecoder().decode(WidgetFortune.self, from: data)
        else {
            return nil
        }

        return HarugiwunEntry(
            date: Date(),
            totalScore: fortune.totalScore ?? 0,
            luckyColorName: fortune.luckyColor ?? "-",
            luckyNumber: fortune.luckyNumber ?? 0,
            summary: fortune.summary ?? "오늘의 운세를 불러오는 중이에요."
        )
    }
}

// MARK: - View

struct HarugiwunWidgetView: View {
    var entry: HarugiwunProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            ZStack {
                Color(UIColor.systemGroupedBackground)
                VStack(spacing: 6) {
                    Image("Mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 70)

                    Text("오늘의 운세")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))

                    Text("\(entry.totalScore)")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(scoreColor(entry.totalScore))

                    HStack(spacing: 8) {
                        Circle()
                            .fill(luckyColorValue(entry.luckyColorName))
                            .frame(width: 10, height: 10)
                        Text(entry.luckyColorName)
                            .font(.system(size: 11))
                        Text("번호 \(entry.luckyNumber)")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                .padding(8)
            }
        default:
            ZStack {
                Color(UIColor.systemGroupedBackground)
                HStack(spacing: 10) {
                    Image("Mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("오늘의 운세 \(entry.totalScore)점")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(scoreColor(entry.totalScore))

                        Text(entry.summary)
                            .font(.system(size: 11))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .lineLimit(2)

                        HStack(spacing: 10) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(luckyColorValue(entry.luckyColorName))
                                    .frame(width: 10, height: 10)
                                Text(entry.luckyColorName)
                            }

                            Text("행운 번호 \(entry.luckyNumber)")
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
                .padding(12)
            }
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return Color(red: 0.25, green: 0.73, blue: 0.47) }
        if score >= 60 { return Color(red: 0.95, green: 0.66, blue: 0.18) }
        return Color(red: 0.92, green: 0.35, blue: 0.35)
    }

    private func luckyColorValue(_ name: String) -> Color {
        switch name {
        case "빨강", "Red":   return .red
        case "파랑", "Blue":  return .blue
        case "초록", "Green": return Color(red: 0.25, green: 0.73, blue: 0.47)
        case "노랑", "Yellow": return .yellow
        case "보라", "Purple": return .purple
        case "주황", "Orange": return .orange
        case "흰색", "White":  return Color(UIColor.systemGray4)
        case "검정", "Black":  return .black
        default:              return Color(UIColor.systemGray4)
        }
    }
}

// MARK: - Widget

struct HarugiwunWidget: Widget {
    let kind: String = "HarugiwunWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HarugiwunProvider()) { entry in
            HarugiwunWidgetView(entry: entry)
        }
        .configurationDisplayName("하루긔운")
        .description("오늘의 점수, 행운 색상과 번호를 보여줘요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
