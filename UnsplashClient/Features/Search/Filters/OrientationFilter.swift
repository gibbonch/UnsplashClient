import Foundation

enum OrientationFilter: SearchFilter, CaseIterable {
    case any
    case landscape
    case portrait
    case square
    
    var type: FilterType { .orientation }
    
    var value: String? {
        switch self {
        case .any:
            return nil
        case .landscape:
            return "landscape"
        case .portrait:
            return "portrait"
        case .square:
            return "squarish"
        }
    }
    
    var text: String {
        switch self {
        case .any:
            return "Any"
        case .landscape:
            return "Landscape"
        case .portrait:
            return "Portrait"
        case .square:
            return "Square"
        }
    }
}
