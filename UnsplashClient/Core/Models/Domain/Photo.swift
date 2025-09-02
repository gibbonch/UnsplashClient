import Foundation

struct Photo {
    
    struct Resolution {
        let width: Int
        let height: Int
    }
    
    struct URLs {
        let raw: URL
        let full: URL
        let regular: URL
        let small: URL
        let thumb: URL
    }
    
    let id: String
    let author: User
    let createdAt: Date
    let resolution: Resolution
    let color: Hex
    let blurHash: Hash
    let description: String
}

typealias Hex = String
typealias Hash = String

struct PhotoWithLikeStatus {
    let photo: Photo
    let isLiked: Bool
}
