import Foundation

protocol PhotoRepositoryProtocol {
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void)
    func fetchPhotos(query: SearchQuery, page: Int, perPage: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void)
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, NetworkError>) -> Void)
}

final class PhotoRepository: PhotoRepositoryProtocol {
    
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void) {
        let endpoint = GetPhotosEndpoint(page: page, perPage: perPage)
        client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let photoDTOs):
                let photos = photoDTOs.compactMap { Photo(dto: $0) }
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPhotos(query: SearchQuery, page: Int, perPage: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void) { }
    
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, NetworkError>) -> Void) {
        let endpoint = GetPhotoEndpoint(id: id)
        client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let photoDTO):
                if let photo = Photo(dto: photoDTO) {
                    completion(.success(photo))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
