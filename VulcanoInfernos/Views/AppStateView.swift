import SwiftUI

struct AppStateView: View {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var appManager = AppManager()
    @StateObject private var state = AppStateManager()
    @StateObject private var fcmManager = FCMManager.shared
        
    var body: some View {
        Group {
            switch state.appState {
            case .fetch:
                LoadingView()
            case .support:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                } else if let fcmToken = fcmManager.fcmToken {
                    WebViewManager(
                        url: NetworkManager.getInitialURL(fcmToken: fcmToken),
                        webManager: state.webManager
                    )
                } else {
                    WebViewManager(
                        url: NetworkManager.initialURL,
                        webManager: state.webManager
                    )
                }
            case .final:
                ContentView()
                    .preferredColorScheme(.light)
                    .environmentObject(appCoordinator)
                    .environmentObject(appManager)
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    AppStateView()
}
