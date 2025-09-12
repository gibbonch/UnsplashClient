import Foundation

protocol SearchRepositoryProtocol {
    
    @discardableResult
    func searchPhotos(
        query: SearchQuery,
        page: Int,
        perPage: Int,
        completion: @escaping (Result<PhotosSearchResult, Error>) -> Void
    ) -> CancellableTask?
}

final class SearchRepository: SearchRepositoryProtocol {
    
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    @discardableResult
    func searchPhotos(
        query: SearchQuery,
        page: Int,
        perPage: Int,
        completion: @escaping (Result<PhotosSearchResult, Error>) -> Void
    ) -> CancellableTask? {
        let endpoint = SearchPhotosEndpoint(searchQuery: query)
        let task = client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let dto):
                let searchResult = PhotosSearchResult(dto: dto)
                completion(.success(searchResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
