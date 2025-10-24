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
    
    var body: some View {
        ZStack {
            // Background
            if let backgroundName = selectedBackground?.imageName {
                Image(backgroundName)
                    .resizable()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Top bar: Back button + Energy display
            VStack {
                HStack {
                    BackButton {
                        appCoordinator.goBack()
                    }
                    
                    Spacer()
                    
                    // Energy progress bar
                    EnergyBar(
                        currentEnergy: Int(sessionEnergy),
                        maxEnergy: Int(1.0),
                        showLabel: true
                    )
                    .frame(width: 180, height: 8)
                }
                Spacer()
            }
            .padding()
            
            // Ring area with actual ring rendering
            ZStack {
                // All 5 rings rendered from largest to smallest
                if !rings.isEmpty {
                    ForEach(rings) { ring in
                        RingView(ring: ring)
                    }
                } else {
                    // Placeholder while rings load
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
            
            // Spin button
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
            
            // Win overlay
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
    
    // MARK: - Ring Initialization
    
    private func initializeRings() {
        rings = GameLogic.initializeRings()
    }
    
    // MARK: - Spin Logic with Animation
    
    private func spinRings() {
        isSpinning = true
        var animationTasks: [Task<Void, Never>] = []
        
        // Animate each ring with different duration and direction
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
        
        // Wait for all animations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            detectAndAwardEnergy()
            isSpinning = false
        }
    }
    
    private func detectAndAwardEnergy() {
        // Detect matches
        let detected = GameLogic.detectMatches(rings: rings)
        matchCount = detected
        
        // Calculate energy
        let earned = GameLogic.calculateEnergy(matchCount: detected)
        earnedEnergy = earned
        
        // Award energy if match found
        if earned > 0 {
            sessionEnergy += earned
            appManager.addEnergy(earned)
            
            // Show win overlay
            showWinOverlay = true
            
            // Auto-dismiss after 2 seconds
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
