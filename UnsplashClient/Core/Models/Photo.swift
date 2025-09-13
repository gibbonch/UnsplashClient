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
    let urls: URLs
    let author: User
    let createdAt: Date?
    let resolution: Resolution
    let color: Hex
    let description: String?
}

typealias Hex = String

struct DetailedPhoto {
    let photo: Photo
    let isLiked: Bool
    let source: PhotoSource
}

enum PhotoSource {
    case remote
    case local(URL)
}
