import SwiftUI

struct BackButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
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
            Image(systemName: "house.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(red: 0.9, green: 0.3, blue: 0.0))
                        .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.1).opacity(0.5), radius: 6, x: 0, y: 3)
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            HStack {
                BackButton(action: {})
                Spacer()
            }
            .padding()
            Spacer()
        }
    }
}
