import SwiftUI

struct FriendsView: View {
    var body: some View {
        List {
            Text("친구 A - 점수 82")
            Text("친구 B - 점수 74")
        }
        .navigationTitle("친구")
    }
}
