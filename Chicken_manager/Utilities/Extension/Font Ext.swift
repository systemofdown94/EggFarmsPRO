import SwiftUI

enum InterFont {
    case bold
    case semibold
    case medium
    
    var name: String {
        switch self {
            case .bold:
                "Inter-Bold"
            case .semibold:
                "Inter-SemiBold"
            case .medium:
                "Inter-Medium"
        }
    }
}

extension Font {
    static func inter(_ font: InterFont, size: CGFloat) -> Font {
        .custom(font.name, size: size)
    }
}
