import SwiftUI

struct FortuneView: View {
    @State private var fortune: FortuneDetailResponse?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("오늘의 총점: \(fortune?.totalScore ?? 0)")
                    .font(.title2)
                    .bold()

                categoryRow("재물", fortune?.moneyScore)
                categoryRow("연애", fortune?.loveScore)
                categoryRow("건강", fortune?.healthScore)
                categoryRow("직장", fortune?.workScore)
                categoryRow("인간관계", fortune?.socialScore)

                Text(fortune?.summary ?? "로딩 중입니다. 잠시만 기다려주세요.")
                    .padding(.top, 8)

                Text(fortune?.detailText ?? "상세 운세는 로딩 중입니다. 잠시만 기다려주세요.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("운세")
        .task {
            fortune = FortuneDetailResponse(
                date: "2026-02-23",
                totalScore: 78,
                moneyScore: 80,
                loveScore: 72,
                healthScore: 75,
                workScore: 79,
                socialScore: 84,
                luckyColor: "Blue",
                luckyNumber: 7,
                summary: "좋은 하루 보내시고 행운 가득한 하루 되세요.",
                detailText: "오늘 하루가 당신에게 따뜻한 결과를 가져다 줄 것입니다."
            )
        }
    }

    private func categoryRow(_ title: String, _ score: Int?) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(score ?? 0)")
                .bold()
        }
    }
}
