import Foundation

protocol PhotoRepositoryProtocol {
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void)
    func fetchPhotos(query: SearchQuery, page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void)
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void)
    func cancelCurrentTask()
}

final class PhotoRepository: PhotoRepositoryProtocol {
    
    private let client: NetworkClientProtocol
    private var currentTask: CancellableTask?
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        let endpoint = GetPhotosEndpoint(page: page, perPage: perPage)
        currentTask = client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let photoDTOs):
                let photos = photoDTOs.compactMap { Photo(dto: $0) }
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPhotos(query: SearchQuery, page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) { }
    
    func fetchPhoto(id: String, completion: @escaping (Result<Photo, Error>) -> Void) {
        let endpoint = GetPhotoEndpoint(id: id)
        currentTask = client.request(endpoint: endpoint) { result in
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
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
}
