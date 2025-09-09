import Foundation

protocol FetchPhotosUseCaseProtocol {
    func execute(page: Int, perPage: Int, with query: SearchQuery?, completion: @escaping (Result<[Photo], Error>) -> Void)
    func cancelCurrentTask()
}

final class FetchPhotosUseCase: FetchPhotosUseCaseProtocol {
    private let photoRepository: PhotoRepositoryProtocol
    
    init(photoRepository: PhotoRepositoryProtocol) {
        self.photoRepository = photoRepository
    }
    
    func execute(page: Int, perPage: Int, with query: SearchQuery? = nil, completion: @escaping (Result<[Photo], Error>) -> Void) {
        if let query {
            searchPhotos(query: query, page: page, perPage: perPage, completion: completion)
        } else {
            fetchPhotos(page: page, perPage: perPage, completion: completion)
        }
    }
    
    func cancelCurrentTask() {
        photoRepository.cancelCurrentTask()
    }
    
    private func searchPhotos(query: SearchQuery, page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        photoRepository.fetchPhotos(query: query, page: page, perPage: perPage) { [weak self] result in
            self?.handleResult(result, completion: completion)
        }
    }
    
    private func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        photoRepository.fetchPhotos(page: page, perPage: perPage) { [weak self] result in
            self?.handleResult(result, completion: completion)
        }
    }
    
    private func handleResult(_ result: Result<[Photo], Error>, completion: @escaping (Result<[Photo], Error>) -> Void) {
        switch result {
        case .success(let photos):
            completion(.success(photos))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
