import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    @State private var shakeId: UUID = UUID()
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
    
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
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar: Back button + Energy display
                HStack {
                    BackButton {
                        appCoordinator.goBack()
                    }
                    
                    Spacer()
                    
                    // Energy display
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.yellow)
                            .font(.system(size: 16))
                        
                        Text("\(appManager.totalEnergy)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Energy progress bar
                VStack(spacing: 4) {
                    Text("Progress to next level")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    EnergyBar(
                        currentEnergy: Int(nextLevelProgress),
                        maxEnergy: Int(1.0),
                        showLabel: false
                    )
                    .frame(height: 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Level grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
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
                    .padding(20)
                }
            }
        }
    }
}

#Preview {
    LevelSelectView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
