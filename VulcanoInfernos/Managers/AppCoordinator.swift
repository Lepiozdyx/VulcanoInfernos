import SwiftUI
import Combine

enum AppScreen: Hashable {
    case mainMenu
    case levelSelect
    case game(levelId: Int)
    case upgrades
    case achievements
    case artifacts
    case settings
}

class AppCoordinator: ObservableObject {
    @Published var currentScreen: AppScreen = .mainMenu
    
    func navigate(to screen: AppScreen) {
        self.currentScreen = screen
    }
    
    func goBack() {
        self.currentScreen = .mainMenu
    }
}
