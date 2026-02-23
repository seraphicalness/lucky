import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        VStack(spacing: 20) {
            Text("?섎（湲곗슫")
                .font(.largeTitle)
                .bold()

            Button(action: mockAppleLogin) {
                Text("Apple濡?濡쒓렇??(Mock)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 24)
        }
    }

    private func mockAppleLogin() {
        session.token = "mock-token"
        session.userId = 1
    }
}
