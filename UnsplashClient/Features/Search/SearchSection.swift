import Foundation

enum SearchSection: Hashable {
    case recent
    case filter(FilterType)
    
    var title: String {
        switch self {
        case .recent:
            return "Recent"
        case .filter(let type):
            return type.title
        }
    }
}

extension FilterType {
    var title: String {
        switch self {
        case .orderedBy:
            return "Ordered by"
        case .orientation:
            return "Orientation"
        }
    }
}
