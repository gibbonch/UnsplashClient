import Foundation

protocol PhotoDetailServiceProtocol {
    func fetchPhoto(with id: String, completion: @escaping (Result<DetailedPhoto, Error>) -> Void)
    func likePhoto(_ photo: Photo)
    func unlikePhoto(with id: String)
}

final class PhotoDetailService: PhotoDetailServiceProtocol {
    
    private let photoRepository: PhotoRepositoryProtocol
    private let favoritesRepository: FavoritesRepositoryProtocol
    
    init(photoRepository: PhotoRepositoryProtocol, favoritesRepository: FavoritesRepositoryProtocol) {
        self.photoRepository = photoRepository
        self.favoritesRepository = favoritesRepository
    }
    
    func fetchPhoto(with id: String, completion: @escaping (Result<DetailedPhoto, any Error>) -> Void) {
        favoritesRepository.fetchFavoritePhoto(with: id) { [weak self] detailedPhoto in
            if let detailedPhoto {
                completion(.success(detailedPhoto))
            } else {
                self?.loadPhoto(with: id, completion: completion)
            }
        }
    }
    
    func likePhoto(_ photo: Photo) {
        favoritesRepository.storeFavoritePhoto(photo)
    }
    
    func unlikePhoto(with id: String) {
        favoritesRepository.deleteFavoritePhoto(with: id)
    }
    
    private func loadPhoto(with id: String, completion: @escaping (Result<DetailedPhoto, any Error>) -> Void) {
        photoRepository.fetchPhoto(id: id) { result in
            switch result {
            case .success(let photo):
                let detailedPhoto = DetailedPhoto(photo: photo, isLiked: false, source: .remote(photo.urls.regular))
                completion(.success(detailedPhoto))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
