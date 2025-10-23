import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    
    init(
        backgroundColor: Color = Color(red: 0.1, green: 0.1, blue: 0.1),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        content
            .padding()
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: 16) {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card Title")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text("Card content goes here")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.gray)
            }
        }
        
        CardView(backgroundColor: Color(red: 0.2, green: 0.1, blue: 0.0)) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Card")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text("With custom background")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.orange)
            }
        }
    }
    .padding()
    .background(Color.black)
}
