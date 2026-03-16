import SwiftUI
import WidgetKit

struct HarugiwunEntry: TimelineEntry {
    let date: Date
    let totalScore: Int
    let summary: String
    let luckyColor: String
    let luckyNumber: Int
    let pending: Bool
    let pendingMessage: String?
}

struct HarugiwunProvider: TimelineProvider {
    func placeholder(in context: Context) -> HarugiwunEntry {
        HarugiwunEntry(
            date: Date(),
            totalScore: 88,
            summary: "오늘은 운이 좋은 날입니다.",
            luckyColor: "Red",
            luckyNumber: 7,
            pending: false,
            pendingMessage: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HarugiwunEntry) -> Void) {
        if let stored = SharedStore.loadWidgetFortune() {
            let entry = HarugiwunEntry(
                date: stored.date,
                totalScore: stored.totalScore ?? 0,
                summary: stored.summary ?? "",
                luckyColor: stored.luckyColor ?? "Gray",
                luckyNumber: stored.luckyNumber ?? 0,
                pending: stored.pending,
                pendingMessage: stored.pendingMessage
            )
            completion(entry)
        } else {
            completion(placeholder(in: context))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HarugiwunEntry>) -> Void) {
        var entry = placeholder(in: context)
        
        if let stored = SharedStore.loadWidgetFortune() {
            entry = HarugiwunEntry(
                date: stored.date,
                totalScore: stored.totalScore ?? 0,
                summary: stored.summary ?? "운세를 확인하려면 앱을 실행하세요",
                luckyColor: stored.luckyColor ?? "Gray",
                luckyNumber: stored.luckyNumber ?? 0,
                pending: stored.pending,
                pendingMessage: stored.pendingMessage
            )
        } else {
            // 데이터가 없으면 'pending' 상태로 가정
            entry = HarugiwunEntry(
                date: Date(),
                totalScore: 0,
                summary: "오늘의 운세를 확인해보세요",
                luckyColor: "Gray",
                luckyNumber: 0,
                pending: true,
                pendingMessage: "앱을 열어 확인하기"
            )
        }

        // 1시간마다 갱신 요청
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct HarugiwunWidgetView: View {
    var entry: HarugiwunProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        ZStack {
            Color("WidgetBackground") // Assets에 추가 필요하거나 시스템 컬러 사용
            
            if entry.pending {
                VStack {
                    Text("오늘의 운세")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.pendingMessage ?? "터치하여 확인")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            } else {
                switch family {
                case .systemSmall:
                    VStack(spacing: 8) {
                        Text("총점")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(entry.totalScore)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(scoreColor(entry.totalScore))
                        Text(entry.luckyColor)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                default:
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(entry.totalScore)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(scoreColor(entry.totalScore))
                            Text("행운의 숫자: \(entry.luckyNumber)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.summary)
                                .font(.subheadline)
                                .bold()
                                .lineLimit(3)
                            
                            HStack {
                                Circle()
                                    .fill(Color(entry.luckyColor)) // 단순 색상 이름 매핑은 주의 필요
                                    .frame(width: 10, height: 10)
                                Text("행운의 색: \(entry.luckyColor)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .blue }
        if score >= 40 { return .orange }
        return .red
    }
}

struct HarugiwunWidget: Widget {
    let kind: String = "HarugiwunWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HarugiwunProvider()) { entry in
            HarugiwunWidgetView(entry: entry)
        }
        .configurationDisplayName("하루기운")
        .description("오늘의 운세 점수를 홈 화면에서 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
