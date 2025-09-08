import Combine
import Foundation

protocol PhotoFeedNavigationResponder: AnyObject {
    func routeToDetail(with id: String)
    func preparingFinished()
}

protocol PhotoFeedViewModelProtocol {
    var feedPhotos: AnyPublisher<[FeedPhotoModel], Never> { get }
    var banner: AnyPublisher<Banner, Never> { get }
    
    func viewLoaded()
    func cellSelected(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    
    func photoResolution(at indexPath: IndexPath) -> Photo.Resolution
}

final class PhotoFeedViewModel: PhotoFeedViewModelProtocol {
    
    // MARK: - Public Properties
    
    weak var responder: PhotoFeedNavigationResponder?
    
    var feedPhotos: AnyPublisher<[FeedPhotoModel], Never> {
        feedPhotosSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var banner: AnyPublisher<Banner, Never> {
        bannerSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private var photos: [Photo] = []
    
    private let fetchPhotosUseCase: FetchPhotosUseCaseProtocol
    private let searchQuery: SearchQuery?
    
    private let feedPhotosSubject = PassthroughSubject<[FeedPhotoModel], Never>()
    private let bannerSubject = PassthroughSubject<Banner, Never>()
    
    private var page: Int = 1
    private let perPage: Int = 20
    private var isFetching = false
    private var isInitialLoad = true
    
    // MARK: - Lifecycle
    
    init(fetchPhotosUseCase: FetchPhotosUseCaseProtocol, searchQuery: SearchQuery? = nil) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.searchQuery = searchQuery
    }
    
    // MARK: - Public Methods
    
    func viewLoaded() {
        fetchPhotos()
    }
    
    func cellSelected(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else {
            return
        }
        let targetID = photos[indexPath.row].id
        responder?.routeToDetail(with: targetID)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row >= photos.count - 5 && !isFetching {
            fetchPhotos()
        }
    }
    
    func photoResolution(at indexPath: IndexPath) -> Photo.Resolution {
        photos[indexPath.row].resolution
    }
    
    // MARK: - Private Methods
    
    private func fetchPhotos() {
        isFetching = true
        fetchPhotosUseCase.execute(page: page, perPage: perPage, with: searchQuery) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let newPhotos):
                let existingIDs = Set(photos.map { $0.id })
                let uniqueNewPhotos = newPhotos.filter { !existingIDs.contains($0.id) }
                
                photos += uniqueNewPhotos
                
                if !uniqueNewPhotos.isEmpty {
                    page += 1
                }
                processPhotos()
                
            case .failure(let error):
                handleError(error)
            }
            
            isFetching = false
            
            if isInitialLoad {
                isInitialLoad = false
                DispatchQueue.main.async {
                    self.responder?.preparingFinished()
                }
            }
        }
    }
    
    private func processPhotos() {
        let feedPhotoModels = photos.map { mapPhoto($0) }
        feedPhotosSubject.send(feedPhotoModels)
    }
    
    private func mapPhoto(_ photo: Photo) -> FeedPhotoModel {
        FeedPhotoModel(
            id: photo.id,
            avatar: photo.author.profileImage.small,
            username: "@\(photo.author.nickname)",
            photo: photo.urls.regular,
            hex: photo.color
        )
    }
    
    private func handleError(_ error: Error) {
        // В данный момент feed может получить только NetworkError.
        // В случае изменения логики в UseCase или Repository, изменить обработку ошибок.
        guard let networkError = error as? NetworkError else { return }
        
    }
}
