import Foundation

struct PhotoDTO: ResponseType {
    let id: String
    let user: UserDTO
    let createdAt: Date
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let description: String?
}

typealias PhotosDTO = [PhotoDTO]
