import SwiftUI
import Combine

@main
struct VulcanoInfernosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppStateView()
        }
    }
}
