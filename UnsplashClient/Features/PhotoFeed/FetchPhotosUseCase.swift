import Foundation

protocol FetchPhotosUseCaseProtocol {
    @discardableResult
    func execute(page: Int, perPage: Int, with query: SearchQuery?, completion: @escaping (Result<[Photo], Error>) -> Void) -> CancellableTask?
}

final class FetchPhotosUseCase: FetchPhotosUseCaseProtocol {
    
    private let photoRepository: PhotoRepositoryProtocol
    private let searchRepository: SearchRepositoryProtocol
    
    init(photoRepository: PhotoRepositoryProtocol, searchRepository: SearchRepositoryProtocol) {
        self.photoRepository = photoRepository
        self.searchRepository = searchRepository
    }
    
    @discardableResult
    func execute(page: Int, perPage: Int, with query: SearchQuery? = nil, completion: @escaping (Result<[Photo], Error>) -> Void) -> CancellableTask? {
        if let query {
            return searchPhotos(query: query, page: page, perPage: perPage, completion: completion)
        } else {
            return fetchPhotos(page: page, perPage: perPage, completion: completion)
        }
    }
    
    private func searchPhotos(query: SearchQuery, page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) -> CancellableTask? {
        let task = searchRepository.searchPhotos(query: query, page: page, perPage: perPage) { result in
            switch result {
            case .success(let searchResult):
                completion(.success(searchResult.photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
    private func fetchPhotos(page: Int, perPage: Int, completion: @escaping (Result<[Photo], Error>) -> Void) -> CancellableTask? {
        let task = photoRepository.fetchPhotos(page: page, perPage: perPage) { result in
            switch result {
            case .success(let photos):
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
