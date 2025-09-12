import UIKit

enum OrderedByFilter: SearchFilter, CaseIterable {
    case relevance
    case newest
    
    var type: FilterType { .orderedBy }
    
    var value: String? {
        switch self {
        case .relevance:
            return "relevance"
        case .newest:
            return "latest"
        }
    }
    
    var text: String {
        switch self {
        case .relevance:
            return "Relevance"
        case .newest:
            return "Newest"
        }
    }
}
