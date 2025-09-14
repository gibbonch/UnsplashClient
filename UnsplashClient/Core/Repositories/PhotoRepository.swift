import Foundation

protocol PhotoRepositoryProtocol {
    
    @discardableResult
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) -> CancellableTask?
    
    @discardableResult
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void) -> CancellableTask?
}

final class PhotoRepository: PhotoRepositoryProtocol {
    
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) -> CancellableTask? {
        let endpoint = GetPhotosEndpoint(page: page, perPage: perPage)
        let task = client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let photoDTOs):
                let photos = photoDTOs.compactMap { Photo(dto: $0) }
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void) -> CancellableTask? {
        let endpoint = GetPhotoEndpoint(id: id)
        let task = client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let photoDTO):
                if let photo = Photo(dto: photoDTO) {
                    completion(.success(photo))
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
