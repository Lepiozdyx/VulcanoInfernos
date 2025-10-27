import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
    @ObservedObject private var sound = SoundManager.shared
    
    @State private var soundEnabled: Bool = true
    @State private var musicEnabled: Bool = true
    @State private var showResetAlert: Bool = false
    
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
            
            Image(.sFrame)
                .resizable()
                .frame(width: 300, height: 270)
                .overlay(alignment: .top) {
                    Image(.button)
                        .resizable()
                        .frame(width: 250, height: 60)
                        .overlay {
                            Text("Settings")
                                .titanFont(18)
                        }
                        .offset(y: -35)
                }
                .overlay {
                    VStack {
                        ToggleRow(
                            label: "Sounds",
                            isOn: sound.isSoundOn) {
                                sound.toggleSound()
                            }
                        
                        ToggleRow(
                            label: "Music",
                            isOn: sound.isMusicOn) {
                                sound.toggleMusic()
                            }
                        
                        Spacer()
                        
                        Button(action: {
                            showResetAlert = true
                        }) {
                            Image(.button)
                                .resizable()
                                .frame(width: 150, height: 50)
                                .overlay {
                                    Text("Reset progress")
                                        .titanFont(12)
                                }
                        }
                    }
                    .padding(20)
                }
            
            if showResetAlert {
                ResetProgressAlert(
                    isPresented: $showResetAlert,
                    onConfirm: {
                        appManager.resetProgress()
                        showResetAlert = false
                    }
                )
            }
        }
    }
}

// MARK: - Reset Progress Alert Component

struct ResetProgressAlert: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Reset Progress?")
                    .titanFont(16)
                
                Text("This will delete all progress. Continue?")
                    .titanFont(12, textAlignment: .center)
                
                HStack(spacing: 12) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(.button)
                            .resizable()
                            .frame(width: 110, height: 40)
                            .overlay {
                                Text("Cancel")
                                    .titanFont(12)
                            }
                    }
                    
                    Button(action: onConfirm) {
                        Image(.button)
                            .resizable()
                            .frame(width: 110, height: 40)
                            .overlay {
                                Text("Reset")
                                    .titanFont(12, color: .yellow)
                            }
                    }
                }
            }
            .padding(24)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            .frame(maxWidth: 300)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinator())
        .environmentObject(AppManager())
}
