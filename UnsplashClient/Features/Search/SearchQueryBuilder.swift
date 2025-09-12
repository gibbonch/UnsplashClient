import Foundation

final class SearchQueryBuilder {
    
    private var text: String
    private var filters: [FilterType: any SearchFilter]
    
    init() {
        text = ""
        filters = Self.defaultFilters
    }
    
    private static var defaultFilters: [FilterType: any SearchFilter] {
        [
            .orderedBy: OrderedByFilter.newest,
            .orientation: OrientationFilter.any,
        ]
    }
    
    @discardableResult
    func text(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func filter(_ filter: any SearchFilter) -> Self {
        filters[filter.type] = filter
        return self
    }
    
    @discardableResult
    func reset() -> Self {
        text = ""
        filters = Self.defaultFilters
        return self
    }
    
    @discardableResult
    func query(_ query: SearchQuery) -> Self {
        text = query.text
        query.filters.forEach { filters[$0.type] = $0 }
        return self
    }
    
    func build() -> SearchQuery {
        SearchQuery(text: text, filters: Array(filters.values))
    }
}
