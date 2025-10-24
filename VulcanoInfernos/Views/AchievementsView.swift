import SwiftUI

struct AchievementsView: View {
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
                            Text("Achievements")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .offset(y: -35)
                }
                .overlay {
                    HStack(spacing: 6) {
                        ForEach(appManager.achievements) { achievement in
                            AchievementCardCircle(achievement: achievement)
                        }
                    }
                }
        }
    }
}

// MARK: - Achievement Card Circle Component

struct AchievementCardCircle: View {
    let achievement: Achievement
    
    var statusText: String {
        achievement.isCompleted ? "Collected" : "Locked"
    }
    
    var statusColor: Color {
        achievement.isCompleted ? .yellow : .white
    }
    
    var body: some View {
        Image(.underlay)
            .resizable()
            .frame(width: 105, height: 200)
            .overlay {
                VStack(spacing: 8) {
                    Image(achievement.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                        .opacity(achievement.isCompleted ? 1.0 : 0.5)
                    
                    Text(achievement.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 90)
                    
                    Spacer()
                    
                    Image(.button)
                        .resizable()
                        .frame(width: 90, height: 32)
                        .overlay {
                            Text(statusText)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(statusColor)
                        }
                        .opacity(achievement.isCompleted ? 1.0 : 0.5)
                }
                .padding(.vertical, 6)
            }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
