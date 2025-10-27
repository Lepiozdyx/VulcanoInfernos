import Foundation

struct MatchResult {
    let groups: [Int]
    let totalEnergy: Int
    let multiplier: Int
}

class GameLogic {
    
    // MARK: - Rune Sequence
    static let runeSequence = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    
    // MARK: - Initialize Rings
    
    static func initializeRings() -> [Ring] {
        let configs = [
            (id: 1, scale: 1.0, minRot: 30, maxRot: 90, duration: 1.2, direction: 1),
            (id: 2, scale: 0.80, minRot: 90, maxRot: 180, duration: 1.4, direction: -1),
            (id: 3, scale: 0.64, minRot: 180, maxRot: 360, duration: 1.6, direction: 1),
            (id: 4, scale: 0.51, minRot: 360, maxRot: 720, duration: 1.8, direction: -1),
            (id: 5, scale: 0.41, minRot: 720, maxRot: 1440, duration: 2.0, direction: 1)
        ]
        
        let possibleAngles = [0.0, 30.0, 60.0, 90.0, 120.0, 150.0, 180.0, 210.0, 240.0, 270.0, 300.0, 330.0]
        
        return configs.map { config in
            Ring(
                id: config.id,
                scale: config.scale,
                currentAngle: possibleAngles.randomElement() ?? 0.0,
                runeSequence: runeSequence,
                minRotation: Double(config.minRot),
                maxRotation: Double(config.maxRot),
                animationDuration: config.duration,
                rotationDirection: config.direction
            )
        }
    }
    
    // MARK: - Rotation Logic
    
    static func calculateRotation(for ring: Ring) -> Double {
        let minSegments = Int(ring.minRotation / 30.0)
        let maxSegments = Int(ring.maxRotation / 30.0)
        let randomSegments = Int.random(in: minSegments...maxSegments)
        let rotation = Double(randomSegments) * 30.0 * Double(ring.rotationDirection)
        return rotation
    }
    
    // MARK: - Angle Alignment
    
    static func snapToNearestSegment(angle: Double) -> Double {
        let segmentAngle = 30.0
        let normalized = angle.truncatingRemainder(dividingBy: 360)
        let adjusted = normalized < 0 ? normalized + 360 : normalized
        let segmentIndex = round(adjusted / segmentAngle)
        let snapped = segmentIndex * segmentAngle
        return snapped.truncatingRemainder(dividingBy: 360)
    }
    
    static func alignAllRings(_ rings: inout [Ring]) {
        for i in 0..<rings.count {
            rings[i].currentAngle = snapToNearestSegment(angle: rings[i].currentAngle)
        }
    }
    
    // MARK: - Match Detection
    
    static func getRuneAtTop(ring: Ring) -> Int {
        let aligned = snapToNearestSegment(angle: ring.currentAngle)
        let segmentIndex = Int(aligned / 30.0) % 12
        return ring.runeSequence[segmentIndex]
    }
    
    static func detectMatches(rings: [Ring]) -> MatchResult {
        let runesAtTop = rings.map { getRuneAtTop(ring: $0) }
        var groups: [Int] = []
        var i = 0
        
        while i < runesAtTop.count {
            var groupSize = 1
            let currentRune = runesAtTop[i]
            
            for j in (i + 1)..<runesAtTop.count {
                if runesAtTop[j] == currentRune {
                    groupSize += 1
                } else {
                    break
                }
            }
            
            if groupSize >= 2 {
                groups.append(groupSize)
            }
            
            i += groupSize
        }
        
        let totalEnergy = calculateEnergy(groups: groups)
        let multiplier = groups.count >= 2 ? 2 : 1
        
        return MatchResult(groups: groups, totalEnergy: totalEnergy, multiplier: multiplier)
    }
    
    // MARK: - Energy Calculation
    
    private static func calculateEnergy(groups: [Int]) -> Int {
        var baseEnergy = 0
        
        for groupSize in groups {
            switch groupSize {
            case 2:
                baseEnergy += 10
            case 3:
                baseEnergy += 30
            case 4:
                baseEnergy += 40
            case 5:
                baseEnergy += 100
            default:
                break
            }
        }
        
        let multiplier = groups.count >= 2 ? 2 : 1
        return baseEnergy * multiplier
    }
}
