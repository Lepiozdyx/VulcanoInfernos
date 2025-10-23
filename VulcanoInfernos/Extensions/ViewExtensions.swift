import SwiftUI

extension View {
    func shake(id: UUID, enabled: Bool = true) -> some View {
        modifier(ShakeModifier(id: id, enabled: enabled))
    }
}

struct ShakeModifier: ViewModifier {
    let id: UUID
    let enabled: Bool
    @State private var isShaking = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? -10 : 0)
            .animation(.easeInOut(duration: 0.1).repeatCount(4, autoreverses: true), value: isShaking)
            .onChange(of: id) { _ in
                if enabled {
                    isShaking = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isShaking = false
                    }
                }
            }
    }
}
