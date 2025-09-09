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
