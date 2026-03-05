import Foundation
import UserNotifications

final class PushNotificationManager {
    
    static let shared = PushNotificationManager()
    
    enum AuthorizationStatus {
        case allowed
        case denied
        case notDetermined
    }
    
    var currentStatus: AuthorizationStatus {
        let semaphore = DispatchSemaphore(value: 0)
        var result: AuthorizationStatus = .notDetermined
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                result = .allowed
            case .denied:
                result = .denied
            case .notDetermined:
                result = .notDetermined
            @unknown default:
                result = .notDetermined
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (AuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let status: AuthorizationStatus
                
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    status = .allowed
                case .denied:
                    status = .denied
                case .notDetermined:
                    status = .notDetermined
                @unknown default:
                    status = .notDetermined
                }
                
                DispatchQueue.main.async {
                    completion(status)
                }
            }
        }
    }
}
