import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var appManager: AppManager
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
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .offset(y: -35)
                }
                .overlay {
                    VStack {
                        ToggleRow(
                            label: "Sounds",
                            isOn: $soundEnabled
                        )
                        
                        ToggleRow(
                            label: "Music",
                            isOn: $musicEnabled
                        )
                        
                        Spacer()
                        
                        Button(action: {
                            showResetAlert = true
                        }) {
                            Image(.button)
                                .resizable()
                                .frame(width: 150, height: 50)
                                .overlay {
                                    Text("Reset Progress")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("This will delete all progress. Continue?")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(.button)
                            .resizable()
                            .frame(width: 110, height: 40)
                            .overlay {
                                Text("Cancel")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                    }
                    
                    Button(action: onConfirm) {
                        Image(.button)
                            .resizable()
                            .frame(width: 110, height: 40)
                            .overlay {
                                Text("Reset")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.red)
                            }
                    }
                }
            }
            .padding(24)
            .background(Color.black.opacity(0.9))
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
