import Foundation

struct EggNote: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var count: Int
    
    init() {
        self.id = UUID()
        self.date = Date()
        self.count = 5
    }
}
