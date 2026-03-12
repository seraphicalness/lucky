import SwiftUI

// MARK: - Gender Option

enum OnboardingGender {
    case female, male
}

// MARK: - OnboardingView

struct OnboardingView: View {
    @EnvironmentObject private var session: SessionStore

    @State private var step = 1

    // Step 1
    @State private var name = ""

    // Step 2
    @State private var birthDate: Date? = nil
    @State private var showBirthDatePicker = false
    @State private var birthHour: Int? = nil
    @State private var showBirthHourPicker = false
    @State private var unknownBirthTime = false

    // Step 3
    @State private var gender: OnboardingGender? = nil

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                headerRow

                switch step {
                case 1:
                    step1View
                case 2:
                    step2View
                default:
                    step3View
                }
            }
        }
        .sheet(isPresented: $showBirthDatePicker) {
            BirthDatePickerSheet(
                selection: Binding(
                    get: { birthDate ?? defaultBirthDate },
                    set: { birthDate = $0 }
                ),
                onConfirm: { showBirthDatePicker = false }
            )
        }
        .sheet(isPresented: $showBirthHourPicker) {
            BirthHourPickerSheet(
                selection: Binding(
                    get: { birthHour ?? 0 },
                    set: { birthHour = $0 }
                ),
                onConfirm: { showBirthHourPicker = false }
            )
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        ZStack {
            HStack {
                if step > 1 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { step -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                }
                Spacer()
            }

            HStack(spacing: 0) {
                ForEach(1...3, id: \.self) { i in
                    Circle()
                        .fill(i == step ? AppTheme.tabGreen : Color(UIColor.systemGray4))
                        .frame(width: 28, height: 28)
                        .overlay {
                            Text("\(i)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    if i < 3 {
                        StepDashedLine()
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            .frame(width: 44, height: 2)
                            .foregroundStyle(Color(UIColor.systemGray4))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Step 1: 이름

    private var step1View: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("이름을 입력해 주세요.")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.top, 40)

            Spacer()

            underlineField(label: "이름") {
                TextField("이름을 입력해 주세요.", text: $name)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 24)

            Spacer()

            nextButton(title: "다음", enabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                withAnimation(.easeInOut(duration: 0.2)) { step = 2 }
            }
        }
    }

    // MARK: - Step 2: 생년월일 / 시간

    private var step2View: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("출생년도와 생일,\n태어난 시를 입력해 주세요.")
                .font(.system(size: 22, weight: .bold))
                .lineSpacing(3)
                .padding(.horizontal, 24)
                .padding(.top, 40)

            Spacer()

            VStack(spacing: 32) {
                underlineField(label: "출생년도") {
                    Button { showBirthDatePicker = true } label: {
                        Text(birthDate.map(formattedDate) ?? "출생년도를 선택해 주세요.")
                            .font(.system(size: 16))
                            .foregroundStyle(birthDate == nil ? Color(UIColor.placeholderText) : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    underlineField(label: "태어난 시") {
                        Button {
                            guard !unknownBirthTime else { return }
                            showBirthHourPicker = true
                        } label: {
                            Text(birthHour.map { "\($0)시" } ?? "태어난 시를 선택해 주세요.")
                                .font(.system(size: 16))
                                .foregroundStyle(
                                    (unknownBirthTime || birthHour == nil)
                                        ? Color(UIColor.placeholderText) : .primary
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .disabled(unknownBirthTime)
                        .opacity(unknownBirthTime ? 0.4 : 1)
                    }

                    Button {
                        unknownBirthTime.toggle()
                        if unknownBirthTime { birthHour = nil }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: unknownBirthTime ? "checkmark.square.fill" : "checkmark.square")
                                .foregroundStyle(unknownBirthTime ? AppTheme.tabGreen : Color(UIColor.systemGray3))
                                .font(.system(size: 16))
                            Text("태어난 시 모름")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            nextButton(
                title: "다음",
                enabled: birthDate != nil && (unknownBirthTime || birthHour != nil)
            ) {
                withAnimation(.easeInOut(duration: 0.2)) { step = 3 }
            }
        }
    }

    // MARK: - Step 3: 성별

    private var step3View: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("성별을 입력해 주세요.")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 24)
                .padding(.top, 40)

            Spacer()

            HStack(spacing: 20) {
                genderCircleButton(.female)
                genderCircleButton(.male)
                Spacer()
            }
            .padding(.horizontal, 24)

            Spacer()

            nextButton(title: "완료", enabled: gender != nil) {
                completeOnboarding()
            }
        }
    }

    private func genderCircleButton(_ option: OnboardingGender) -> some View {
        let isSelected = gender == option
        let icon = option == .female ? "figure.stand.dress" : "figure.stand"
        let label = option == .female ? "여자" : "남자"

        return Button { gender = option } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 34, weight: .ultraLight))
                    .foregroundStyle(AppTheme.tabGreen)
                Text(label)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
            }
            .frame(width: 116, height: 116)
            .background(isSelected ? AppTheme.tabGreen.opacity(0.2) : Color.white)
            .clipShape(Circle())
        }
    }

    // MARK: - Reusable Builders

    @ViewBuilder
    private func underlineField<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
            content()
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func nextButton(title: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(enabled ? AppTheme.tabGreen : Color(UIColor.systemGray4))
                .clipShape(Capsule())
        }
        .disabled(!enabled)
        .padding(.horizontal, 24)
        .padding(.bottom, 44)
    }

    // MARK: - Helpers

    private var defaultBirthDate: Date {
        Calendar.current.date(from: DateComponents(year: 1995, month: 1, day: 1)) ?? Date()
    }

    private func formattedDate(_ date: Date) -> String {
        let cal = Calendar.current
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return "\(y)년 \(m)월 \(d)일"
    }

    private func completeOnboarding() {
        // TODO: Call AuthAPI.socialLogin(...)
        /*
        Task {
            do {
                let req = SocialLoginRequest(
                    providerUserId: "test-user-id", // Real ID from Apple Auth
                    nickname: name,
                    birthDate: birthDate,
                    ...
                )
                let res = try await AuthAPI.login(req)
                session.token = res.token
                session.userId = res.userId
                session.needsOnboarding = false
            } catch {
                print("Login failed: \(error)")
            }
        }
        */
        
        // Temporary Mock for Testing
        print("Mock Login with: Name=\(name), Birth=\(String(describing: birthDate)), Gender=\(String(describing: gender))")
        session.token = "mock-token-for-testing"
        session.userId = 1
        session.needsOnboarding = false
    }
}

// MARK: - Dashed Step Line Shape

private struct StepDashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return p
    }
}

// MARK: - Picker Sheets

private struct BirthDatePickerSheet: View {
    @Binding var selection: Date
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 8)
            DatePicker("", selection: $selection, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal)
            Divider()
            Button("확인") { onConfirm() }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.tabGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}

private struct BirthHourPickerSheet: View {
    @Binding var selection: Int
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 8)
            Picker("시간", selection: $selection) {
                ForEach(0..<24, id: \.self) { h in
                    Text("\(h)시").tag(h)
                }
            }
            .pickerStyle(.wheel)
            .padding(.horizontal)
            Divider()
            Button("확인") { onConfirm() }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.tabGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}
