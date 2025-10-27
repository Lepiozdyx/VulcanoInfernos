import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var phase
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @ObservedObject private var sound = SoundManager.shared
    
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
        .onAppear {
            OrientationManager.shared.lockLandscape()
            if sound.isMusicOn {
                sound.playMusic()
            }
        }
        .onChange(of: phase) { state in
            switch state {
            case .active:
                OrientationManager.shared.lockLandscape()
                sound.playMusic()
            case .background, .inactive:
                sound.stopMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
