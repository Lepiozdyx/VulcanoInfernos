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
                Text("Upgrades Screen")
                    .foregroundStyle(.white)
            case .achievements:
                Text("Achievements Screen")
                    .foregroundStyle(.white)
            case .artifacts:
                Text("Artifacts Screen")
                    .foregroundStyle(.white)
            case .settings:
                Text("Settings Screen")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
