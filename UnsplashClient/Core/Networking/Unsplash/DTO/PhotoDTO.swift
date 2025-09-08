import Foundation

struct PhotoDTO: Decodable {
    
    struct URLsDTO: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    let id: String
    let urls: URLsDTO
    let user: UserDTO
    let createdAt: Date
    let width: Int
    let height: Int
    let color: String
    let description: String?
}

typealias PhotosDTO = [PhotoDTO]

extension Photo {
    init?(dto: PhotoDTO) {
        guard let mappedAuthor = User(dto: dto.user),
              let mappedURLs = Photo.URLs(dto: dto.urls) else {
            return nil
        }
        
        id = dto.id
        urls = mappedURLs
        author = mappedAuthor
        createdAt = dto.createdAt
        resolution = Resolution(width: dto.width, height: dto.height)
        color = dto.color
        description = dto.description
    }
}

extension Photo.URLs {
    
    init?(dto: PhotoDTO.URLsDTO) {
        guard let rawURL = URL(string: dto.raw),
              let fullURL = URL(string: dto.full),
              let regularURL = URL(string: dto.regular),
              let smallURL = URL(string: dto.small),
              let thumbURL = URL(string: dto.thumb) else {
            return nil
        }
        raw = rawURL
        full = fullURL
        regular = regularURL
        small = smallURL
        thumb = thumbURL
    }
}
