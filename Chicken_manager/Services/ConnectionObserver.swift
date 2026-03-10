import UIKit
import Network
import Combine

final class ConnectionObserver: ObservableObject {

    static let shared = ConnectionObserver()
    
    private let monitor = NWPathMonitor()
    
    @Published private(set) var isConnected: Bool?
    
    private init() {
        checkInternetConnection()
    }
    
    private func checkInternetConnection() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isConnected = true
            } else if path.status == .unsatisfied {
                self.isConnected = false
            }
        }
        
        monitor.start(queue: .global())
    }
}
