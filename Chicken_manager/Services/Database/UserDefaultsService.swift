import Foundation

final class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func save<T: Codable>(_ value: T, forKey key: AppStorageKey) async {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key.rawValue)
        } catch {
            assertionFailure("Encoding error: \(error)")
        }
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: AppStorageKey) async -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            assertionFailure("Decoding error: \(error)")
            return nil
        }
    }
    
    func remove(forKey key: AppStorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
