import SwiftUI
import WidgetKit

struct HarugiwunEntry: TimelineEntry {
    let date: Date
    let totalScore: Int
    let categories: [Int]
}

struct HarugiwunProvider: TimelineProvider {
    func placeholder(in context: Context) -> HarugiwunEntry {
        HarugiwunEntry(date: Date(), totalScore: 75, categories: [70, 80, 75, 78, 72])
    }

    func getSnapshot(in context: Context, completion: @escaping (HarugiwunEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HarugiwunEntry>) -> Void) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct HarugiwunWidgetView: View {
    var entry: HarugiwunProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                Text("?ㅻ뒛 ?댁꽭")
                Text("\(entry.totalScore)")
                    .font(.largeTitle)
                    .bold()
            }
            .padding()
        default:
            VStack(alignment: .leading, spacing: 8) {
                Text("?ㅻ뒛 ?댁꽭 \(entry.totalScore)")
                    .font(.headline)
                HStack {
                    Image(systemName: "dollarsign.circle")
                    Image(systemName: "heart.circle")
                    Image(systemName: "cross.case.circle")
                    Image(systemName: "briefcase.circle")
                    Image(systemName: "person.2.circle")
                }
                .font(.title3)
            }
            .padding()
        }
    }
}

struct HarugiwunWidget: Widget {
    let kind: String = "HarugiwunWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HarugiwunProvider()) { entry in
            HarugiwunWidgetView(entry: entry)
        }
        .configurationDisplayName("?섎（湲곗슫")
        .description("?ㅻ뒛???댁꽭 ?먯닔瑜??뺤씤?섏꽭??")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
