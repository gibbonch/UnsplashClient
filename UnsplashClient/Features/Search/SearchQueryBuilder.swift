struct SearchQueryBuilder {
    
    private var text: String
    private var orderedBy: SearchQuery.OrderedBy
    private var orientation: SearchQuery.Orientation
    private var color: SearchQuery.Color
    
    init(searchQuery: SearchQuery = .base) {
        text = searchQuery.text
        orderedBy = searchQuery.orderedBy
        orientation = searchQuery.orientation
        color = searchQuery.color
    }
    
    private init(
        text: String,
        orderedBy: SearchQuery.OrderedBy,
        orientation: SearchQuery.Orientation,
        color: SearchQuery.Color
    ) {
        self.text = text
        self.orderedBy = orderedBy
        self.orientation = orientation
        self.color = color
    }
    
    func text(_ text: String) -> SearchQueryBuilder {
        SearchQueryBuilder(text: text, orderedBy: orderedBy, orientation: orientation, color: color)
    }
    
    func orderedBy(_ orderedBy: SearchQuery.OrderedBy) -> SearchQueryBuilder {
        SearchQueryBuilder(text: text, orderedBy: orderedBy, orientation: orientation, color: color)
    }
    
    func orientation(_ orientation: SearchQuery.Orientation) -> SearchQueryBuilder {
        SearchQueryBuilder(text: text, orderedBy: orderedBy, orientation: orientation, color: color)
    }
    
    func color(_ color: SearchQuery.Color) -> SearchQueryBuilder {
        SearchQueryBuilder(text: text, orderedBy: orderedBy, orientation: orientation, color: color)
    }
    
    func build() -> SearchQuery {
        return SearchQuery(text: text, orderedBy: orderedBy, orientation: orientation, color: color)
    }
}

extension SearchQuery {
    static var base: Self {
        SearchQuery(
            text: "",
            orderedBy: .newest,
            orientation: .any,
            color: .any
        )
    }
}
