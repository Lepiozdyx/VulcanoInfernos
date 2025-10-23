import Foundation

class GameLogic {
    
    // MARK: - Rune Sequence
    // Fixed rune order for ring.png (clockwise from 12 o'clock)
    // Position 0 = 12 o'clock (0°)
    // Position 1 = 1 o'clock (30°)
    // ... continuing clockwise
    static let runeSequence = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    
    // MARK: - Initialize Rings
    
    static func initializeRings() -> [Ring] {
        let configs = [
            (id: 1, scale: 1.0, minRot: 30, maxRot: 90, duration: 1.2, direction: 1),
            (id: 2, scale: 0.85, minRot: 90, maxRot: 180, duration: 1.4, direction: -1),
            (id: 3, scale: 0.7, minRot: 180, maxRot: 360, duration: 1.6, direction: 1),
            (id: 4, scale: 0.55, minRot: 360, maxRot: 720, duration: 1.8, direction: -1),
            (id: 5, scale: 0.4, minRot: 720, maxRot: 1440, duration: 2.0, direction: 1)
        ]
        
        return configs.map { config in
            Ring(
                id: config.id,
                scale: config.scale,
                currentAngle: Double.random(in: 0..<360),
                runeSequence: runeSequence,
                minRotation: Double(config.minRot),
                maxRotation: Double(config.maxRot),
                animationDuration: config.duration,
                rotationDirection: config.direction
            )
        }
    }
    
    // MARK: - Match Detection
    
    static func getRuneAtTop(ring: Ring) -> Int {
        // Normalize angle to 0-360 range
        let normalized = ring.currentAngle.truncatingRemainder(dividingBy: 360)
        let adjusted = normalized < 0 ? normalized + 360 : normalized
        
        // Calculate which segment (0-11) is at top
        // Each segment spans 30° (360° / 12)
        let segmentIndex = Int(round(adjusted / 30.0)) % 12
        
        // Return the rune ID at this position
        return ring.runeSequence[segmentIndex]
    }
    
    static func detectMatches(rings: [Ring]) -> Int {
        let runesAtTop = rings.map { getRuneAtTop(ring: $0) }
        
        var matchCount = 1
        let firstRune = runesAtTop[0]
        
        // Count consecutive matches starting from Ring 1
        for i in 1..<runesAtTop.count {
            if runesAtTop[i] == firstRune {
                matchCount += 1
            } else {
                break
            }
        }
        
        return matchCount >= 2 ? matchCount : 0
    }
    
    // MARK: - Energy Calculation
    
    static func calculateEnergy(matchCount: Int) -> Int {
        switch matchCount {
        case 0...1:
            return 0
        case 2:
            return 10
        case 3:
            return 50
        case 4:
            return 150
        case 5:
            return 500
        default:
            return 0
        }
    }
}

