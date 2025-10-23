import Foundation

struct Artifact: Identifiable {
    let id: Int
    let name: String
    let legend: String
    let energyRequired: Int
    var isUnlocked: Bool
    let imageName: String
}

