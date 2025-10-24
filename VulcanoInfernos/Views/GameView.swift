import SwiftUI

struct GameView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    @State private var rings: [Ring] = []
    @State private var isSpinning = false
    @State private var sessionEnergy = 0
    @State private var matchCount = 0
    @State private var showWinOverlay = false
    @State private var earnedEnergy = 0
    
    let levelId: Int
    
    var selectedBackground: GameBackground? {
        appManager.backgrounds.first { $0.id == appManager.selectedBackgroundId }
    }
    
    var energyBarValues: (current: Int, max: Int) {
        let totalEnergy = appManager.totalEnergy
        let unlockedCount = appManager.levels.filter { $0.isUnlocked }.count
        let nextLevelIndex = min(unlockedCount, appManager.levels.count - 1)
        let nextLevelRequired = appManager.levels[nextLevelIndex].energyRequired
        
        if nextLevelIndex == appManager.levels.count - 1 && appManager.levels[nextLevelIndex].isUnlocked {
            return (nextLevelRequired, nextLevelRequired)
        }
        
        let currentRequired = nextLevelIndex > 0 ? appManager.levels[nextLevelIndex - 1].energyRequired : 0
        let range = nextLevelRequired - currentRequired
        let progress = totalEnergy - currentRequired
        
        return (progress, range)
    }
    
    var body: some View {
        ZStack {
            if let backgroundName = selectedBackground?.imageName {
                Image(backgroundName)
                    .resizable()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    BackButton {
                        appCoordinator.goBack()
                    }
                    
                    Spacer()
                    
                    EnergyBar(
                        currentEnergy: energyBarValues.current,
                        maxEnergy: energyBarValues.max,
                        showLabel: true
                    )
                    .frame(width: 180)
                }
                Spacer()
            }
            .padding()
            
            ZStack {
                if !rings.isEmpty {
                    ForEach(rings) { ring in
                        RingView(ring: ring)
                    }
                } else {
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                        .frame(height: 200)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "rings")
                            .font(.system(size: 40))
                            .foregroundStyle(.orange)
                        
                        Text("Level \(levelId)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Loading rings...")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .frame(maxHeight: 300)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PrimaryButton(
                        title: isSpinning ? "WAIT..." : "SPIN",
                        action: {
                            if !isSpinning {
                                spinRings()
                            }
                        }
                    )
                    .disabled(isSpinning)
                    .opacity(isSpinning ? 0.7 : 1.0)
                }
            }
            
            if showWinOverlay && matchCount >= 2 {
                VStack(spacing: 16) {
                    Text("MATCH!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.yellow)

                    HStack {
                        Text("+\(earnedEnergy)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.yellow)
                        
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .frame(width: 20, height: 25)
                            .foregroundStyle(.yellow)
                    }
                }
                .padding()
                .background(
                    Image(.xsFrame)
                        .resizable()
                )
            }
        }
        .onAppear {
            initializeRings()
        }
    }
    
    private func initializeRings() {
        rings = GameLogic.initializeRings()
    }
    
    private func spinRings() {
        isSpinning = true
        var animationTasks: [Task<Void, Never>] = []
        
        for (index, _) in rings.enumerated() {
            let task = Task {
                let ring = rings[index]
                let randomRotation = Double.random(in: ring.minRotation...ring.maxRotation)
                let rotation = randomRotation * Double(ring.rotationDirection)
                
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 10)) {
                    rings[index].currentAngle += rotation
                }
                
                try? await Task.sleep(nanoseconds: UInt64(ring.animationDuration * 1_000_000_000))
            }
            animationTasks.append(task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            detectAndAwardEnergy()
            isSpinning = false
        }
    }
    
    private func detectAndAwardEnergy() {
        let detected = GameLogic.detectMatches(rings: rings)
        matchCount = detected
        
        let earned = GameLogic.calculateEnergy(matchCount: detected)
        earnedEnergy = earned
        
        if earned > 0 {
            sessionEnergy += earned
            appManager.addEnergy(earned)
            
            showWinOverlay = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showWinOverlay = false
            }
        }
    }
}

#Preview {
    GameView(levelId: 1)
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
