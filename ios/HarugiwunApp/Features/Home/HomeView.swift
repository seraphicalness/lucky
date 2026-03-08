import SwiftUI

struct HomeView: View {
    @State private var totalScore: Int = 78
    @State private var summary: String = "좋은 하루 보내시고 행운 가득한 하루 되세요."

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("오늘의 운세")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    Text("\(totalScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(AppTheme.tabGreen)
                    Text("총점")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(summary)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .padding()
        }
        .navigationTitle("홈")
    }
}
