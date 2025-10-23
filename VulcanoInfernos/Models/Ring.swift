import Foundation

struct Ring: Identifiable {
    let id: Int
    let scale: CGFloat
    var currentAngle: Double
    let runeSequence: [Int]
    let minRotation: Double
    let maxRotation: Double
    let animationDuration: Double
    let rotationDirection: Int
}
