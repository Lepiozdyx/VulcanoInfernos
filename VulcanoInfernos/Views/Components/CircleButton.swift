import SwiftUI

struct CircleButton: View {
    let content: String
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
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
            Text(content)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(isEnabled ? .white : .gray)
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
        CircleButton(content: "1", isEnabled: true) {}
        CircleButton(content: "2", isEnabled: false) {}
        CircleButton(content: "3", isEnabled: true) {}
    }
    .padding()
    .background(Color.black)
}
