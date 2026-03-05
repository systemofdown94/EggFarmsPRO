import Foundation

struct UserModel: Codable, Hashable {
    let id: UUID
    var name: String
    var type: UserType
    
    init() {
        self.id = UUID()
        self.name = "Billy"
        self.type = .keeper
    }
}
