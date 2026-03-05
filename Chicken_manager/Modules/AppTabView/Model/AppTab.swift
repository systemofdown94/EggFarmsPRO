import UIKit

enum AppTab: Identifiable, CaseIterable {
    case chickens
    case eggLog
    case statistics
    case settings
    
    var id: Self {
        self
    }
    
    var icon: ImageResource {
        switch self {
            case .chickens:
                    .Icons.AppTab.chickens
            case .eggLog:
                    .Icons.AppTab.eggLog
            case .statistics:
                    .Icons.AppTab.statistics
            case .settings:
                    .Icons.AppTab.settings
        }
    }
    
    var title: String {
        switch self {
            case .chickens:
                 "Chickens"
            case .eggLog:
                "Egg Log"
            case .statistics:
                "Statistics"
            case .settings:
                "Settings"
        }
    }
}
