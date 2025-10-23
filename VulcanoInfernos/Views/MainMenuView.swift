import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Background
            Image("menu_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 16) {
                    PrimaryButton(
                        title: "Start Eruption",
                        action: {
                            appCoordinator.navigate(to: .levelSelect)
                        }
                    )
                    
                    PrimaryButton(
                        title: "Upgrades",
                        action: {
                            appCoordinator.navigate(to: .upgrades)
                        }
                    )
                    
                    PrimaryButton(
                        title: "Achievements",
                        action: {
                            appCoordinator.navigate(to: .achievements)
                        }
                    )
                    
                    PrimaryButton(
                        title: "Artifacts",
                        action: {
                            appCoordinator.navigate(to: .artifacts)
                        }
                    )
                    
                    PrimaryButton(
                        title: "Settings",
                        action: {
                            appCoordinator.navigate(to: .settings)
                        }
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            // Audio initialization placeholder
            // AudioManager.shared.playBackgroundMusic()
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(AppCoordinator())
}
