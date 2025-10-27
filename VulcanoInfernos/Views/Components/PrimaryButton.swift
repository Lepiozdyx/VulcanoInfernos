import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        } label: {
            Image(.button)
                .resizable()
                .frame(width: 200, height: 70)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .overlay {
                    Text(title)
                        .titanFont(18)
                }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Start Game") {}
        PrimaryButton(title: "Continue") {}
    }
    .padding()
}
