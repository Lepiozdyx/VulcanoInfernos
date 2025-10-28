import UIKit
import SwiftUI
import Combine
import FirebaseMessaging
@preconcurrency import WebKit

class NetworkManager: ObservableObject {
    @Published private(set) var targetURL: URL?
    static let infernoURL = "https://vulcaninfern.com/client"
    private let storage: UserDefaults
    private var didSaveURL = false
    private let requestTimeout: TimeInterval = 5.0
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadProvenURL()
    }
    
    static func isInitialURL(_ url: URL) -> Bool {
        guard let baseURL = URL(string: infernoURL),
              url.host == baseURL.host,
              url.path == baseURL.path else {
            return false
        }
        return true
    }
    
    static func getInitialURL(fcmToken: String) -> URL {
        guard var components = URLComponents(string: infernoURL) else {
            fatalError("Invalid BASE_URL: \(infernoURL)")
        }
        
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "fcm", value: fcmToken))
        components.queryItems = queryItems
        
        guard let url = components.url else {
            fatalError("Failed to create URL with FCM token")
        }
        
        return url
    }
    
    static var initialURL: URL {
        guard let url = URL(string: infernoURL) else {
            fatalError("Invalid BASE_URL: \(infernoURL)")
        }
        return url
    }
    
    func checkURL(_ url: URL) {
        if didSaveURL {
            return
        }
        
        guard !isInvalidURL(url) else {
            return
        }
        
        storage.set(url.absoluteString, forKey: "savedurl")
        targetURL = url
        didSaveURL = true
    }
    
    private func loadProvenURL() {
        if let urlString = storage.string(forKey: "savedurl") {
            if let url = URL(string: urlString) {
                targetURL = url
                didSaveURL = true
            } else {
                print("Error: load - \(urlString)")
            }
        }
    }
    
    private func isInvalidURL(_ url: URL) -> Bool {
        let invalidURLs = ["about:blank", "about:srcdoc"]
        
        if invalidURLs.contains(url.absoluteString) {
            return true
        }
        
        return false
    }
    
    func checkInitialURL() async throws -> Bool {
        let fcmToken = await FCMManager.shared.waitForToken()
        let initialURL = Self.getInitialURL(fcmToken: fcmToken)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = requestTimeout
        
        let session = URLSession(configuration: configuration)
        
        var request = URLRequest(url: initialURL)
        request.setValue(getUAgent(forWebView: false), forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = requestTimeout
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            if (400...599).contains(httpResponse.statusCode) {
                return false
            }

            return true
            
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getUAgent(forWebView: Bool = false) -> String {
        if forWebView {
            let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            let agent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            return agent
        } else {
            let agent = "TestRequest/1.0 CFNetwork/1410.0.3 Darwin/22.4.0"
            return agent
        }
    }
}

struct WebViewManager: UIViewRepresentable {
    let url: URL
    let webManager: NetworkManager
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.bounces = true
        webView.customUserAgent = webManager.getUAgent(forWebView: true)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewManager
        
        init(_ parent: WebViewManager) {
            self.parent = parent
            super.init()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let finalURL = webView.url else {
                return
            }
            
            if !NetworkManager.isInitialURL(finalURL) {
                parent.webManager.checkURL(finalURL)
            } else {
                print("WebView: Still on initial URL")
            }
        }
    }
}

class FCMManager: ObservableObject {
    static let shared = FCMManager()
    
    @Published private(set) var fcmToken: String?
    private var continuation: CheckedContinuation<String, Never>?
    
    private init() {}
    
    func setToken(_ token: String) {
        self.fcmToken = token
        continuation?.resume(returning: token)
        continuation = nil
    }
    
    func waitForToken() async -> String {
        if let existingToken = fcmToken {
            return existingToken
        }
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }
}
