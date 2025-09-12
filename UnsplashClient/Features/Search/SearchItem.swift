import UIKit

enum SearchItem: Hashable {
    case recent(RecentQueryCellModel)
    case filter(FilterCellModel)
}

struct FilterCellModel: Hashable {
    let filter: AnySearchFilter
    let isSelected: Bool
    let image: UIImage?
    
    init(filter: any SearchFilter, isSelected: Bool, image: UIImage? = nil) {
        self.filter = filter.eraseToAnySearchFilter()
        self.isSelected = isSelected
        self.image = image
    }
}

struct RecentQueryCellModel: Hashable {
    let id: String
    let text: String
}

enum SearchButtonState {
    case hidden
    case loading
    case search(String)
    case empty
}
