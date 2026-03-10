import UIKit

struct Chicken: Identifiable, Equatable, Hashable {
    let id: UUID
    var image: UIImage?
    var name: String
    var breed: String
    var birthDate: Date
    var eggsPerWeek: Int
    var eggNotes: [EggNote]
    
    var isReady: Bool {
        image != nil && name != "" && breed != ""
    }
    
    init(isMock: Bool) {
        self.id = UUID()
        self.image = isMock ? UIImage(resource: .Icons.Mock.mockChicken) : nil
        self.name = isMock ? "Name" : ""
        self.breed = isMock ? "Breed" : ""
        self.birthDate = Date()
        self.eggsPerWeek = 5
        self.eggNotes = isMock ? [EggNote()] : []
    }
    
    init(from dto: ChickenDTO) {
        self.id = dto.id
        self.name = dto.name
        self.breed = dto.breed
        self.birthDate = dto.birthDate
        self.eggsPerWeek = dto.eggsPerWeek
        self.eggNotes = dto.eggNotes
    }
}

extension Chicken {
    var eggsThisWeek: Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return 0
        }
        
        return eggNotes
            .filter { weekInterval.contains($0.date) }
            .reduce(0) { $0 + $1.count }
    }
    
    var averageEggsPerWeek: Double {
        let calendar = Calendar.current
        let now = Date()
        
        let weeksSinceBirth = calendar.dateComponents([.weekOfYear],
                                                      from: birthDate,
                                                      to: now).weekOfYear ?? 0
        
        guard weeksSinceBirth > 0 else { return Double(eggsPerWeek) }
        
        let baseEggs = weeksSinceBirth * eggsPerWeek
        let notesEggs = eggNotes.reduce(0) { $0 + $1.count }
        let totalEggs = baseEggs + notesEggs
        
        return Double(totalEggs) / Double(weeksSinceBirth)
    }
    
    var eggScore: Double {
        let calendar = Calendar.current
        let now = Date()
        
        let weeksSinceBirth = calendar.dateComponents([.weekOfYear], from: birthDate, to: now).weekOfYear ?? 0
        let notesSum = eggNotes.reduce(0) { $0 + $1.count }
        
        return averageEggsPerWeek + Double(weeksSinceBirth) + Double(notesSum)
    }
}
