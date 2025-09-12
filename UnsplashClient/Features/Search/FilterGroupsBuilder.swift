import UIKit

final class FilterGroupsBuilder {
    
    private let availableFilters: [FilterType: [AnySearchFilter]] = [
        .orderedBy: OrderedByFilter.allCases.map { $0.eraseToAnySearchFilter() },
        .orientation: OrientationFilter.allCases.map { $0.eraseToAnySearchFilter() },
        .color: ColorFilter.allCases.map { $0.eraseToAnySearchFilter() },
    ]
    
    private let colorImageService = ColorImageService()
    
    func buildFilterGroups(for query: SearchQuery) -> [FilterGroup] {
        return FilterType.allCases.compactMap { type in
            guard let filters = availableFilters[type] else { return nil }
            
            let models = filters.map { filter in
                let isSelected = isFilterSelected(filter, in: query)
                
                if case .color = type, let value = filter.value {
                    let hex = ColorFilter.hex(for: value)
                    let image = colorImageService.createImageForColor(hex: hex)
                    return FilterCellModel(filter: filter, isSelected: isSelected, image: image)
                }
                
                return FilterCellModel(filter: filter, isSelected: isSelected)
            }
            
            return FilterGroup(type: type, filterModels: models)
        }
    }
    
    private func isFilterSelected(_ filter: AnySearchFilter, in query: SearchQuery) -> Bool {
        return query.filters.contains { queryFilter in
            queryFilter.type == filter.type && queryFilter.value == filter.value
        }
    }
}

struct FilterGroup {
    let type: FilterType
    let filterModels: [FilterCellModel]
}
