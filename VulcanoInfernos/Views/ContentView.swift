import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch appCoordinator.currentScreen {
            case .mainMenu:
                MainMenuView()
            case .levelSelect:
                LevelSelectView()
            case .game(let levelId):
                GameView(levelId: levelId)
            case .upgrades:
                UpgradesView()
            case .achievements:
                AchievementsView()
            case .artifacts:
                ArtifactsView()
            case .settings:
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
