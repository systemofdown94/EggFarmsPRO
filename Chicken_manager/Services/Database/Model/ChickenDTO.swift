import Foundation

struct ChickenDTO: Identifiable, Codable {
    let id: UUID
    var name: String
    var breed: String
    var birthDate: Date
    var eggsPerWeek: Int
    var eggNotes: [EggNote]
    
    init(from model: Chicken) {
        self.id = model.id
        self.name = model.name
        self.breed = model.breed
        self.birthDate = model.birthDate
        self.eggsPerWeek = model.eggsPerWeek
        self.eggNotes = model.eggNotes
    }
}
