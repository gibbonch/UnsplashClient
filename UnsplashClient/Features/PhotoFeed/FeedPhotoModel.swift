import Foundation

struct FeedPhotoModel {
    let id: String
    let avatar: URL
    let username: String
    let photo: URL
    let hex: String
}

extension FeedPhotoModel: Hashable {
    
    static func == (lhs: FeedPhotoModel, rhs: FeedPhotoModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SizedFeedPhotoModel {
    let model: FeedPhotoModel
    let imageSize: CGSize
}
