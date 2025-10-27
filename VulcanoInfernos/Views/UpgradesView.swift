import SwiftUI

struct UpgradesView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        ZStack {
            Image(.menuBg)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    BackButton {
                        appCoordinator.goBack()
                    }
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            
            Image(.lFrame)
                .resizable()
                .frame(width: 600, height: 270)
                .overlay(alignment: .top) {
                    Image(.button)
                        .resizable()
                        .frame(width: 250, height: 60)
                        .overlay {
                            Text("Upgrades")
                                .titanFont(18)
                        }
                        .offset(y: -35)
                }
                .overlay {
                    HStack(spacing: 16) {
                        ForEach(appManager.backgrounds) { background in
                            BackgroundCard(
                                background: background,
                                isSelected: appManager.selectedBackgroundId == background.id,
                                action: {
                                    appManager.selectBackground(background.id)
                                }
                            )
                        }
                    }
                }
        }
    }
}

// MARK: - Background Card Component

struct BackgroundCard: View {
    let background: GameBackground
    let isSelected: Bool
    let action: () -> Void
    
    var buttonTitle: String {
        if !background.isUnlocked {
            return "Locked"
        }
        return isSelected ? "Selected" : "Select"
    }
    
    var body: some View {
        Image(background.imageName + "_preview")
            .resizable()
            .frame(width: 125, height: 200)
            .opacity(background.isUnlocked ? 1.0 : 0.5)
            .overlay(alignment: .bottom) {
                Button(action: {
                    SoundManager.shared.play()
                    action()
                }) {
                    Image(.button)
                        .resizable()
                        .frame(width: 105, height: 40)
                        .overlay {
                            Text(buttonTitle)
                                .titanFont(12, color: isSelected ? .yellow : .white)
                        }
                        .padding(.bottom, 6)
                }
                .disabled(!background.isUnlocked)
                .opacity(background.isUnlocked ? 1.0 : 0.6)
            }
    }
}

#Preview {
    UpgradesView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
