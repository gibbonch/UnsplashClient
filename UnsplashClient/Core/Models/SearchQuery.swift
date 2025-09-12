import Foundation

struct SearchQuery {
    let text: String
    let filters: [any SearchFilter]
}

protocol SearchFilter: Hashable {
    var type: FilterType { get }
    var value: String? { get }
    var text: String { get }
}

enum FilterType: String, CaseIterable {
    case orderedBy = "order_by"
    case orientation
    case color
}
