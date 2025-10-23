import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    @State private var shakeId: UUID = UUID()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var nextLevelProgress: Double {
        let currentEnergy = appManager.totalEnergy
        let unlockedCount = appManager.levels.filter { $0.isUnlocked }.count
        let nextLevelIndex = min(unlockedCount, appManager.levels.count - 1)
        let nextLevelRequired = appManager.levels[nextLevelIndex].energyRequired
        
        if nextLevelIndex == appManager.levels.count - 1 && appManager.levels[nextLevelIndex].isUnlocked {
            return 1.0
        }
        
        let currentRequired = nextLevelIndex > 0 ? appManager.levels[nextLevelIndex - 1].energyRequired : 0
        let range = Double(nextLevelRequired - currentRequired)
        let progress = Double(currentEnergy - currentRequired) / range
        return min(max(progress, 0), 1.0)
    }
    
    var body: some View {
        ZStack {
            Image(.menuBg)
                .resizable()
                .ignoresSafeArea()
            
            // Top bar: Back button + Energy display
            VStack {
                HStack {
                    BackButton {
                        appCoordinator.goBack()
                    }
                    
                    Spacer()
                    
                    // Energy progress bar
                    EnergyBar(
                        currentEnergy: Int(nextLevelProgress),
                        maxEnergy: Int(1.0),
                        showLabel: true
                    )
                    .frame(width: 200, height: 8)
                }
                
                Spacer()
            }
            .padding()
            
            VStack {
                Spacer()
                
                // Level grid
                Image(.sFrame)
                    .resizable()
                    .overlay(alignment: .top) {
                        Image(.button)
                            .resizable()
                            .frame(width: 250, height: 60)
                            .overlay {
                                Text("Level Select")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .offset(y: -35)
                    }
                    .overlay {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(appManager.levels) { level in
                                CircleButton(
                                    content: {
                                        if level.isUnlocked {
                                            Text("\(level.id)")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundStyle(.white)
                                        } else {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.gray)
                                        }
                                    },
                                    isEnabled: level.isUnlocked,
                                    action: {
                                        if level.isUnlocked {
                                            appManager.setCurrentLevel(level.id)
                                            appCoordinator.navigate(to: .game(levelId: level.id))
                                        } else {
                                            shakeId = UUID()
                                        }
                                    }
                                )
                                .shake(id: shakeId, enabled: !level.isUnlocked)
                            }
                        }
                        .padding(30)
                    }
                    .frame(width: 350, height: 280)
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    LevelSelectView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
