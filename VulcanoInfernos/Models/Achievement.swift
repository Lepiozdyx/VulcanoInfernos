import Foundation

struct Achievement: Identifiable {
    let id: Int
    let title: String
    let description: String
    var isCompleted: Bool
    let iconName: String
}

