import SwiftUI

struct StoreView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    
    let products = [
        StoreProduct(id: "com.harugiwun.points.small", name: "소량 포인트", points: 1000, price: "990원"),
        StoreProduct(id: "com.harugiwun.points.medium", name: "중량 포인트", points: 2500, price: "1,990원"),
        StoreProduct(id: "com.harugiwun.points.large", name: "대량 포인트", points: 4000, price: "2,990원")
    ]

    var body: some View {
        List {
            Section(header: Text("포인트 충전")) {
                ForEach(products) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text("\(product.points) P")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(product.price) {
                            Task {
                                await session.purchasePoints(productId: product.id, amount: product.points)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.tabGreen)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section(header: Text("무료 포인트")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("광고 보고 포인트 받기")
                            .font(.headline)
                        Text("100 P (오늘 \(session.dailyAdCount)/5)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("시청하기") {
                        Task {
                            await session.claimAdReward()
                        }
                    }
                    .disabled(session.dailyAdCount >= 5)
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("상점")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(session.points) P")
                    .bold()
            }
        }
    }
}
