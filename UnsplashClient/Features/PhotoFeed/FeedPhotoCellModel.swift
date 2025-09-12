import Foundation

struct FeedPhotoCellModel {
    let id: String
    let avatar: URL
    let username: String
    let photo: URL
    let hex: String
}

extension FeedPhotoCellModel: Hashable {
    
    static func == (lhs: FeedPhotoCellModel, rhs: FeedPhotoCellModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SizedFeedPhotoCellModel {
    let model: FeedPhotoCellModel
    let imageSize: CGSize
}
