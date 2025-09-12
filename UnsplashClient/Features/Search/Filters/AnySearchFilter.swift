import UIKit

struct AnySearchFilter: SearchFilter, Hashable {
    var type: FilterType
    var value: String?
    var text: String
    
    init(filter: any SearchFilter) {
        type = filter.type
        value = filter.value
        text = filter.text
    }
    
    static func == (lhs: AnySearchFilter, rhs: AnySearchFilter) -> Bool {
        lhs.type == rhs.type && lhs.value == rhs.value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
}

extension SearchFilter {
    func eraseToAnySearchFilter() -> AnySearchFilter {
        .init(filter: self)
    }
}
