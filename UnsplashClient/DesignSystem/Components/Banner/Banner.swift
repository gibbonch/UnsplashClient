import UIKit

struct Banner {
    
    enum BunnerType {
        case notification
        case error
    }
    
    let title: String
    let subtitle: String?
    let type: BunnerType
    
    init(title: String, subtitle: String? = nil, type: BunnerType) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}
