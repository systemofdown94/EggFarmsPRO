import Combine
import UIKit

final class ChickensViewModel: ObservableObject {
    
    private let storage = UserDefaultsService.shared
    private let fileManager = ImageFileStorageService.shared
    
    @Published var navigationPath: [ChickensScreen] = []
    
    @Published private(set) var chickens: [Chicken] = []
}

// MARK: - Public API:
extension ChickensViewModel {
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
    
    func save(_ chicken: Chicken) {
        Task { [weak self] in
            guard let self else { return }
            
            var chickensDTO = await self.storage.get([ChickenDTO].self, forKey: .chickens) ?? []
        
            if let index = chickensDTO.firstIndex(where: { $0.id == chicken.id }) {
                chickensDTO[index] = ChickenDTO(from: chicken)
            } else {
                chickensDTO.append(ChickenDTO(from: chicken))
            }
            
            if let image = chicken.image {
                try? self.fileManager.save(image: image, uuid: chicken.id)
            }
            
            await self.storage.save(chickensDTO, forKey: .chickens)
            
            await MainActor.run {
                if let index = self.chickens.firstIndex(where: { $0.id == chicken.id }) {
                    self.chickens[index] = chicken
                } else {
                    self.chickens.append(chicken)
                }
                
                self.navigationPath = []
            }
        }
    }
    
    func remove(_ chicken: Chicken) {
        Task { [weak self] in
            guard let self else { return }
            
            var chickensDTO = await self.storage.get([ChickenDTO].self, forKey: .chickens) ?? []
            
            if let index = chickensDTO.firstIndex(where: { $0.id == chicken.id }) {
                chickensDTO.remove(at: index)
            }
        
            try? self.fileManager.remove(uuid: chicken.id)
            
            await self.storage.save(chickensDTO, forKey: .chickens)
            
            await MainActor.run {
                if let index = self.chickens.firstIndex(where: { $0.id == chicken.id }) {
                    self.chickens.remove(at: index)
                }
            }
        }
    }
}
