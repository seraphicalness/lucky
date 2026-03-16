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
            Spacer()
            Text("\(score ?? 0)")
                .bold()
        }
    }
}
