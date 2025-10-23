import SwiftUI
import Combine

@main
struct VulcanoInfernosApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var appManager = AppManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(appManager)
        }
    }
}
