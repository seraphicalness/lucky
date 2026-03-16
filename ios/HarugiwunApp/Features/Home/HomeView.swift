import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("오늘의 운세")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "p.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("\(session.points) P")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }

                VStack(spacing: 12) {
                    Text("\(session.todayTotalScore)")
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

                Text(session.todaySummary)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .padding()
        }
        .navigationTitle("홈")
        .task {
            await session.fetchWidgetFortune()
        }
    }
}
