import SwiftUI

struct CircleButton<Content: View>: View {
    let content: () -> Content
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    init(@ViewBuilder content: @escaping () -> Content, isEnabled: Bool, action: @escaping () -> Void) {
        self.content = content
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button {
            guard isEnabled else { return }
            SoundManager.shared.play()
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
            content()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Image(.circleButton)
                        .resizable()
                        .scaledToFit()
                )
                .scaleEffect(isPressed && isEnabled ? 0.9 : 1.0)
                .opacity(isEnabled ? 1.0 : 0.5)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    HStack(spacing: 12) {
        CircleButton(content: {
            Text("1")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }, isEnabled: true) {}
        CircleButton(content: {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundStyle(.gray)
        }, isEnabled: false) {}
    }
}
