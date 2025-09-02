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

extension Photo {
    init?(dto: PhotoDTO) {
        guard let mappedAuthor = User(dto: dto.user) else {
            return nil
        }
        
        id = dto.id
        author = mappedAuthor
        createdAt = dto.createdAt
        resolution = Resolution(width: dto.width, height: dto.height)
        color = dto.color
        blurHash = dto.blurHash
        description = dto.description
    }
}
