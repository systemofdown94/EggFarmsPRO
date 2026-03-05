import UIKit

enum Page2Data: Identifiable, CaseIterable {
    case data1
    case data2
    case data3
    
    var id: Self {
        self
    }
    
    var icon: ImageResource {
        switch self {
            case .data1:
                    .Icons.Onboarding.chicken
            case .data2:
                    .Icons.Onboarding.egg
            case .data3:
                    .Icons.Onboarding.graph
        }
    }
    
    var title: String {
        switch self {
            case .data1:
                "Create your chickens"
            case .data2:
                "Track your eggs"
            case .data3:
                "Monitor productivity"
        }
    }
}
