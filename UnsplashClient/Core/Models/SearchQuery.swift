import Foundation

struct SearchQuery {
    
    enum OrderedBy {
        case relevance
        case newest
    }
    
    enum Orientation {
        case any
        case portrait
        case landscape
        case square
    }
    
    enum Color {
        case any
        case backAndWhite
        case white
        case black
        case yellow
        case orange
        case red
        case purple
        case magenta
        case green
        case teal
        case blue
    }
    
    let text: String
    let orderedBy: OrderedBy
    let orientation: Orientation
    let color: Color
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

struct SearchQueryBuilder {
    
    private var text: String
    private var orderedBy: SearchQuery.OrderedBy
    private var orientation: SearchQuery.Orientation
    private var color: SearchQuery.Color
    
    init(searchQuery: SearchQuery) {
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
