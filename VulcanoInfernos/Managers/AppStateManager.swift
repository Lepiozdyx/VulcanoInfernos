import Foundation
import Combine

@MainActor
final class AppStateManager: ObservableObject {
    enum AppState {
        case fetch
        case support
        case final
    }
    
    @Published private(set) var appState: AppState = .fetch
    let webManager: NetworkManager
    
    private var timeoutTask: Task<Void, Never>?
    private let maxLoadingTime: TimeInterval = 8.0
    
    init(webManager: NetworkManager) {
        self.webManager = webManager
    }
    
    convenience init() {
        self.init(webManager: NetworkManager())
    }
    
    func stateCheck() {
        timeoutTask?.cancel()
        
        Task { @MainActor in
            do {
                if webManager.targetURL != nil {
                    updateState(.support)
                    return
                }
                
                let shouldShowWebView = try await webManager.checkInitialURL()
                
                if shouldShowWebView {
                    updateState(.support)
                } else {
                    updateState(.final)
                }
            } catch {
                updateState(.final)
            }
        }
        
        startTimeoutTask()
    }
    
    private func updateState(_ newState: AppState) {
        timeoutTask?.cancel()
        timeoutTask = nil
        appState = newState
    }
    
    private func startTimeoutTask() {
        timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(maxLoadingTime * 1_000_000_000))
                
                if self.appState == .fetch {
                    self.appState = .final
                }
            } catch {
                print("Timeout task cancelled")
            }
        }
    }
    
    deinit {
        timeoutTask?.cancel()
    }
}
