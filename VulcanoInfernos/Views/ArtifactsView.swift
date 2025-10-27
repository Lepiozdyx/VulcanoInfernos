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
                            Text("Artifacts")
                                .titanFont(18)
                        }
                        .offset(y: -35)
                }
                .overlay {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 5), spacing: 4) {
                        ForEach(appManager.artifacts) { artifact in
                            ArtifactCard(
                                artifact: artifact,
                                onTap: {
                                    selectedArtifact = artifact
                                }
                            )
                        }
                    }
                    .padding()
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
        Button(action: {
            SoundManager.shared.play()
            onTap()
        }) {
            Image(.xsFrame)
                .resizable()
                .frame(width: 100, height: 110)
                .overlay {
                    VStack(spacing: 2) {
                        Image(artifact.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .grayscale(artifact.isUnlocked ? 0 : 1)
                            .overlay {
                                if !artifact.isUnlocked {
                                    Image(.lock)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                }
                            }
                        
                        Text(artifact.name)
                            .titanFont(10, textAlignment: .center)
                            .frame(height: 24)
                    }
                    .padding(10)
                }
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
                    SoundManager.shared.play()
                    onClose()
                }
            
            Image(.lFrame)
                .resizable()
                .frame(width: 370, height: 270)
                .overlay {
                    VStack(spacing: 16) {
                        Image(artifact.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        Text(artifact.name)
                            .titanFont(18)
                        
                        Text(artifact.legend)
                            .titanFont(12, textAlignment: .center)
                            .lineLimit(5)
                            .frame(maxWidth: 250)
                        
                        if !artifact.isUnlocked {
                            HStack(spacing: 2) {
                                Image(systemName: "bolt.fill")
                                    .resizable()
                                    .foregroundStyle(.yellow)
                                    .frame(width: 15, height: 20)
                                
                                Text("\(artifact.energyRequired) to unlock")
                                    .titanFont(12)
                            }
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        SoundManager.shared.play()
                        onClose()
                    }) {
                        Image(.x)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
        }
    }
}

#Preview {
    ArtifactsView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
