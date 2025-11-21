import SwiftUI

struct AppStateView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var appManager = AppManager()
    @StateObject private var manager = AppStateManager()
        
    var body: some View {
        Group {
            switch manager.appState {
            case .request:
                LoadingView()
                
            case .support:
                if let url = manager.networkManager.gameURL {
                    WKWebViewManager(
                        url: url,
                        webManager: manager.networkManager
                    )
                } else {
                    WKWebViewManager(
                        url: NetworkManager.initialURL,
                        webManager: manager.networkManager
                    )
                }
                
            case .loading:
                ContentView()
                    .preferredColorScheme(.light)
                    .environmentObject(appCoordinator)
                    .environmentObject(appManager)
            }
        }
        .onAppear {
            manager.stateRequest()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppCoordinator())
}
