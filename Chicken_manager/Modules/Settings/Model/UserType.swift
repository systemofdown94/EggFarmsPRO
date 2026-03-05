import UIKit

enum UserType: Identifiable, CaseIterable, Codable {
    case keeper
    case steward
    case enthusiast
    case collector
    case guardian
    case handler
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
            case .keeper:
                "Beginner Poultry"
            case .steward:
                "Novice Flock"
            case .enthusiast:
                "Backyard Coop"
            case .collector:
                "Aspiring Egg"
            case .guardian:
                "Rising Roost"
            case .handler:
                "Homestead Hen"
        }
    }
    
    var subtitle: String {
        switch self {
            case .keeper:
                "Keeper"
            case .steward:
                "Steward"
            case .enthusiast:
                "Enthusiast"
            case .collector:
                "Collector"
            case .guardian:
                "Guardian"
            case .handler:
                "Handler"
        }
    }
    
    var icon: ImageResource {
        switch self {
            case .keeper:
                    .Icons.Settings.keeper
            case .steward:
                    .Icons.Settings.steward
            case .enthusiast:
                    .Icons.Settings.enthusiast
            case .collector:
                    .Icons.Settings.collector
            case .guardian:
                    .Icons.Settings.guardian
            case .handler:
                    .Icons.Settings.handler
        }
    }
}
