import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Background
            Image(.menuBg)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            VStack(spacing: 14) {
                PrimaryButton(
                    title: "Start Eruption",
                    action: {
                        appCoordinator.navigate(to: .levelSelect)
                    }
                )
                
                HStack(spacing: 16) {
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
                }
                
                HStack(spacing: 12) {
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
