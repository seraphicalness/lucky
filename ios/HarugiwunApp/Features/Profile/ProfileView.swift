import SwiftUI

struct ProfileView: View {
    @State private var nickname: String = ""
    @State private var birthDate: Date = Date()
    @State private var hasBirthTime = false
    @State private var birthTime: Date = Date()

    var body: some View {
        Form {
            Section("湲곕낯 ?뺣낫") {
                TextField("?됰꽕??, text: $nickname)
                DatePicker("?앸뀈?붿씪", selection: $birthDate, displayedComponents: .date)
                Toggle("?쒖뼱???쒓컙 ?낅젰", isOn: $hasBirthTime)
                if hasBirthTime {
                    DatePicker("?쒖뼱???쒓컙", selection: $birthTime, displayedComponents: .hourAndMinute)
                }
            }

            Button("???) {
                // TODO: ?꾨줈??API ?곕룞
            }
        }
        .navigationTitle("?꾨줈??)
    }
}
