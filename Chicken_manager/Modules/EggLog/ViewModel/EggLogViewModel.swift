import Foundation
import Combine

final class EggLogViewModel: ObservableObject {
    
    private let storage = UserDefaultsService.shared
    private let fileManager = ImageFileStorageService.shared
    
    @Published var navigationPath: [EgglogScreens] = []
    @Published var currentChicken = Chicken(isMock: true)
    
    @Published private(set) var chickens: [Chicken] = []
}

// MARK: - Public API:
extension EggLogViewModel {
    func loadChickens() {
        Task { [weak self] in
            guard let self else { return }
            
            let chickensDTO = await self.storage.get([ChickenDTO].self, forKey: .chickens) ?? []
            let chickens = chickensDTO.map { Chicken(from: $0) }
            
            let chickensWithImages: [Chicken] = await withTaskGroup(of: Chicken.self) { group in
                var newChickens: [Chicken] = []
                
                for chicken in chickens {
                    group.addTask {
                        let image = await self.fileManager.load(uuid: chicken.id)
                        var newChicken  = chicken
                        
                        newChicken.image = image
                        
                        return newChicken
                    }
                    
                    for await chicken in group {
                        newChickens.append(chicken)
                    }
                }
                
                return newChickens
            }
            
            await MainActor.run {
                self.chickens = chickensWithImages
            }
        }
    }
    
    func save(_ note: EggNote) {
        Task { [weak self] in
            guard let self else { return }
            
            var chickensDTO = await self.storage.get([ChickenDTO].self, forKey: .chickens) ?? []
            
            if let chickenIndex = chickensDTO.firstIndex(where: { $0.id == self.currentChicken.id }) {
                if let noteIndex = self.chickens[chickenIndex].eggNotes.firstIndex(where: { $0.id == note.id }) {
                    chickensDTO[chickenIndex].eggNotes[noteIndex] = note
                } else {
                    chickensDTO[chickenIndex].eggNotes.append(note)
                }
                
                await self.storage.save(chickensDTO, forKey: .chickens)
                
                await MainActor.run {
                    guard let uiChickenIndex = self.chickens.firstIndex(where: { $0.id == self.currentChicken.id }) else { return }
                    
                    if let uiNoteIndex = self.chickens[uiChickenIndex].eggNotes.firstIndex(where: { $0.id == note.id }) {
                        self.chickens[uiChickenIndex].eggNotes[uiNoteIndex] = note
                    } else {
                        self.chickens[uiChickenIndex].eggNotes.append(note)
                    }
                    
                    self.navigationPath = []
                }
            }
        }
    }
    
    func removeEgg(_ note: EggNote) {
        Task { [weak self] in
            guard let self else { return }
            
            var chickensDTO = await self.storage.get([ChickenDTO].self, forKey: .chickens) ?? []
            
            if let chickenIndex = chickensDTO.firstIndex(where: { $0.id == self.currentChicken.id }),
               let noteIndex = chickensDTO[chickenIndex].eggNotes.firstIndex(where: { $0.id == note.id }) {
                chickensDTO[chickenIndex].eggNotes.remove(at: noteIndex)
                
                await self.storage.save(chickensDTO, forKey: .chickens)
                
                await MainActor.run {
                    guard let uiChickenIndex = self.chickens.firstIndex(where: { $0.id == self.currentChicken.id }),
                          let noteIndex = self.chickens[uiChickenIndex].eggNotes.firstIndex(where: { $0.id == note.id }) else { return }
                    
                    self.chickens[uiChickenIndex].eggNotes.remove(at: noteIndex)
                    self.currentChicken.eggNotes.remove(at: noteIndex)
                }
            }
        }
    }
}
