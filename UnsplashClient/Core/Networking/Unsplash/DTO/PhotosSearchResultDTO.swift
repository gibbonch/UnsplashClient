import Foundation

struct PhotosSearchResultDTO: Decodable {
    let total: Int
    let results: PhotosDTO
}

extension PhotosSearchResult {
    
    init(dto: PhotosSearchResultDTO) {
        total = dto.total
        photos = dto.results.compactMap { Photo(dto: $0) }
    }
}
