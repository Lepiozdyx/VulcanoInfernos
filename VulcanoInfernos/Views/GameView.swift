import SwiftUI

struct GameView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    @State private var rings: [Ring] = []
    @State private var isSpinning = false
    @State private var sessionEnergy = 0
    @State private var matchResult: MatchResult?
    @State private var showWinOverlay = false
    @State private var showMissOverlay = false
    
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
    
    var currentStage: Int {
        let progress = Double(energyBarValues.current) / Double(max(energyBarValues.max, 1))
        if progress < 0.33 {
            return 1
        } else if progress < 0.67 {
            return 2
        } else {
            return 3
        }
    }
    
    var body: some View {
        ZStack {
            if let backgroundName = selectedBackground?.imageName {
                Image(backgroundName)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: -10) {
                    Spacer()
                    
                    Image("stage\(currentStage)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .zIndex(1)
                        .offset(x: 20)
                        .animation(.easeInOut(duration: 0.5), value: currentStage)
                    
                    Image(.vulcan)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 170)
                }
                .padding(.bottom)

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
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.yellow.opacity(0.4))
                    .frame(width: 10, height: 130)
                
                Spacer()
            }
            .padding(.top, 20)
            
            ZStack {
                if !rings.isEmpty {
                    ForEach(rings) { ring in
                        RingView(ring: ring).opacity(0.8)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(.ring)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                        
                        Text("Level \(levelId)")
                            .titanFont(18)
                        
                        Text("Loading rings...")
                            .titanFont(10)
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
            
            if showWinOverlay, let result = matchResult, result.totalEnergy > 0 {
                HStack {
                    VStack(spacing: 16) {
                        Text("MATCH!")
                            .titanFont(28, color: .yellow)
                            .shadow(color: .yellow, radius: 5)

                        HStack {
                            Text("+\(result.totalEnergy)")
                                .titanFont(28, color: .yellow)
                                .shadow(color: .yellow, radius: 5)
                            
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .frame(width: 24, height: 30)
                                .foregroundStyle(.yellow)
                                .shadow(color: .yellow, radius: 5)
                        }
                        
                        if result.multiplier > 1 {
                            Image(.X_2)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .rotationEffect(Angle(degrees: 25))
                        }
                    }
                    .rotationEffect(Angle(degrees: -25))
                    .scaleEffect(showWinOverlay ? 1.0 : 0.5)
                    .opacity(showWinOverlay ? 1.0 : 0.0)
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
            
            if showMissOverlay {
                HStack {
                    Spacer()
                    
                    Text("MISS")
                        .titanFont(24, color: .red)
                        .shadow(color: .red.opacity(0.5), radius: 5)
                        .scaleEffect(showMissOverlay ? 1.0 : 0.5)
                        .opacity(showMissOverlay ? 1.0 : 0.0)
                        .offset(y: showMissOverlay ? 0 : 30)
                        .rotationEffect(Angle(degrees: 25))
                }
                .padding(.horizontal, 40)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showWinOverlay)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showMissOverlay)
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
                let rotation = GameLogic.calculateRotation(for: ring)
                
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 10)) {
                    rings[index].currentAngle += rotation
                }
                
                try? await Task.sleep(nanoseconds: UInt64(ring.animationDuration * 1_000_000_000))
                
                rings[index].currentAngle = GameLogic.snapToNearestSegment(angle: rings[index].currentAngle)
            }
            animationTasks.append(task)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            detectAndAwardEnergy()
            isSpinning = false
        }
    }
    
    private func detectAndAwardEnergy() {
        GameLogic.alignAllRings(&rings)
        
        let result = GameLogic.detectMatches(rings: rings)
        matchResult = result
        
        if result.totalEnergy > 0 {
            sessionEnergy += result.totalEnergy
            appManager.addEnergy(result.totalEnergy)
            
            showWinOverlay = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showWinOverlay = false
            }
        } else {
            showMissOverlay = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showMissOverlay = false
            }
        }
    }
}

#Preview {
    GameView(levelId: 1)
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
