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
        Button(action: {
            guard isEnabled else { return }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }) {
            content()
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    Circle()
                        .fill(
                            isEnabled ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.9, green: 0.3, blue: 0.0), Color(red: 0.7, green: 0.15, blue: 0.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: isEnabled ? Color(red: 1.0, green: 0.4, blue: 0.1).opacity(0.5) : Color.clear, radius: 6, x: 0, y: 3)
                )
                .scaleEffect(isPressed && isEnabled ? 0.92 : 1.0)
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
        CircleButton(content: {
            Text("3")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }, isEnabled: true) {}
    }
    .padding()
    .background(Color.black)
}
