import SwiftUI

struct ArtifactsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    @State private var selectedArtifact: Artifact?
    
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
                    
                    HStack(spacing: 8) {
                        Image(.energy)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("\(appManager.totalEnergy)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing)
                }
                .padding()
                
                Spacer()
            }
            
            Image(.lFrame)
                .resizable()
                .frame(width: 600, height: 300)
                .overlay(alignment: .top) {
                    Image(.button)
                        .resizable()
                        .frame(width: 250, height: 60)
                        .overlay {
                            Text("Artifacts")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .offset(y: -35)
                }
                .overlay {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                            ForEach(appManager.artifacts) { artifact in
                                ArtifactCard(
                                    artifact: artifact,
                                    onTap: {
                                        selectedArtifact = artifact
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            
            if let artifact = selectedArtifact {
                ArtifactLoreOverlay(artifact: artifact) {
                    selectedArtifact = nil
                }
            }
        }
    }
}

// MARK: - Artifact Card Component

struct ArtifactCard: View {
    let artifact: Artifact
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(artifact.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .opacity(artifact.isUnlocked ? 1.0 : 0.4)
                    .grayscale(artifact.isUnlocked ? 0 : 1)
                
                Text(artifact.name)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 24)
                
                if !artifact.isUnlocked {
                    HStack(spacing: 2) {
                        Image(.lock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 8)
                        
                        Text("\(artifact.energyRequired)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(6)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        }
        .opacity(artifact.isUnlocked ? 1.0 : 0.7)
    }
}

// MARK: - Artifact Lore Overlay Component

struct ArtifactLoreOverlay: View {
    let artifact: Artifact
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(.x)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding()
                
                Image(artifact.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                
                Text(artifact.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(artifact.legend)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(5)
                    .frame(maxWidth: 250)
                
                Spacer()
            }
            .padding(20)
            .background(Color.black.opacity(0.9))
            .cornerRadius(12)
            .frame(maxWidth: 300)
        }
    }
}

#Preview {
    ArtifactsView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
