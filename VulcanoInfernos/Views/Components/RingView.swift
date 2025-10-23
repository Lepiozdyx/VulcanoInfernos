import SwiftUI

struct RingView: View {
    let ring: Ring
    
    var body: some View {
        Image(.ring)
            .resizable()
            .scaledToFit()
            .scaleEffect(ring.scale)
            .rotationEffect(.degrees(ring.currentAngle))
    }
}

#Preview {
    let previewRing = Ring(
        id: 1,
        scale: 1.0,
        currentAngle: 0,
        runeSequence: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        minRotation: 30,
        maxRotation: 90,
        animationDuration: 1.2,
        rotationDirection: 1
    )
    
    return RingView(ring: previewRing)
        .frame(height: 250)
}

