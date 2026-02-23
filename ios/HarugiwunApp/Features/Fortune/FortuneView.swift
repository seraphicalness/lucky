import SwiftUI

struct FortuneView: View {
    @State private var fortune: FortuneDetailResponse?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("?ㅻ뒛??珥앹젏: \(fortune?.totalScore ?? 0)")
                    .font(.title2)
                    .bold()

                categoryRow("湲덉쟾", fortune?.moneyScore)
                categoryRow("?곗븷", fortune?.loveScore)
                categoryRow("嫄닿컯", fortune?.healthScore)
                categoryRow("??, fortune?.workScore)
                categoryRow("?멸컙愿怨?, fortune?.socialScore)

                Text(fortune?.summary ?? "?붿빟???ш린???쒖떆?⑸땲??")
                    .padding(.top, 8)

                Text(fortune?.detailText ?? "?곸꽭 ?댁꽭媛 ?ш린???쒖떆?⑸땲??")
                    .foregroundStyle(.secondary)

                NavigationLink("?꾨줈???ㅼ젙") {
                    ProfileView()
                }
            }
            .padding()
        }
        .navigationTitle("?섎（湲곗슫")
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
                summary: "臾대궃?섍퀬 ?덉젙?곸씤 ?섎（?덉슂.",
                detailText: "??臾대━ ?놁씠 ?먮쫫???硫?醫뗭? 寃곌낵媛 ?섏샃?덈떎."
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
