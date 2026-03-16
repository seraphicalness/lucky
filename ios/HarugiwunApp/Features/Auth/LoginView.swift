import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        VStack(spacing: 20) {
            Text("하루긔운")
                .font(.largeTitle)
                .bold()

            Button(action: mockAppleLogin) {
                Text("Apple로 로그인(Mock)")
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
        session.startOnboarding(providerId: "apple-user-1234")
    }
}
