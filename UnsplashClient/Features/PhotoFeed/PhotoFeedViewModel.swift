import Combine
import Foundation

protocol PhotoFeedNavigationResponder: AnyObject {
    func routeToDetail(with id: String)
    func preparingFinished()
}

protocol BannerPresenter: AnyObject {
    func presentBanner(_ banner: Banner)
}

protocol PhotoFeedViewModelProtocol {
    var feedState: AnyPublisher<PhotoFeedState, Never> { get }
    var banner: AnyPublisher<Banner, Never> { get }
    var isRefreshing: AnyPublisher<Bool, Never> { get }
    
    func viewLoaded()
    func cellSelected(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    func retryButtonTapped()
    func refreshFeed()
    
    func photoResolution(at indexPath: IndexPath) -> Photo.Resolution
}

final class PhotoFeedViewModel: PhotoFeedViewModelProtocol {
    
    // MARK: - Internal Properties
    
    weak var responder: PhotoFeedNavigationResponder?
    weak var bannerPresenter: BannerPresenter?
    
    var feedState: AnyPublisher<PhotoFeedState, Never> {
        feedStateSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var banner: AnyPublisher<Banner, Never> {
        bannerSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isRefreshing: AnyPublisher<Bool, Never> {
        refreshSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private var photos: [Photo] = []
    
    private let fetchPhotosUseCase: FetchPhotosUseCaseProtocol
    private let searchQuery: SearchQuery?
    
    private let feedStateSubject = CurrentValueSubject<PhotoFeedState, Never>(.initial)
    private let bannerSubject = PassthroughSubject<Banner, Never>()
    private let refreshSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var page: Int = 1
    private let perPage: Int = 20
    private var isFetching = false
    private var currentTask: CancellableTask?
    private var isInitialLoading = true
    
    private var currentError: Error?
    
    // MARK: - Lifecycle
    
    init(fetchPhotosUseCase: FetchPhotosUseCaseProtocol, searchQuery: SearchQuery? = nil) {
        self.fetchPhotosUseCase = fetchPhotosUseCase
        self.searchQuery = searchQuery
    }
    
    // MARK: - Internal Methods
    
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
    
    func retryButtonTapped() {
        currentTask?.cancel()
        fetchPhotos()
    }
    
    func refreshFeed() {
        refreshSubject.send(true)
        currentTask?.cancel()
        currentTask = nil
        fetchPhotos()
    }
    
    func photoResolution(at indexPath: IndexPath) -> Photo.Resolution {
        photos[indexPath.row].resolution
    }
    
    // MARK: - Private Methods
    
    private func fetchPhotos() {
        isFetching = true
        currentTask = fetchPhotosUseCase.execute(page: page, perPage: perPage, with: searchQuery) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let newPhotos):
                let existingIDs = Set(photos.map { $0.id })
                let uniqueNewPhotos = newPhotos.filter { !existingIDs.contains($0.id) }
                
                if refreshSubject.value {
                    photos = uniqueNewPhotos
                } else {
                    photos += uniqueNewPhotos
                }
                
                page += 1
                
                processPhotos()
                currentError = nil
                
            case .failure(let error):
                handleError(error)
            }
            
            isFetching = false
            refreshSubject.send(false)
            
            if isInitialLoading {
                DispatchQueue.main.async {
                    self.isInitialLoading = false
                    self.responder?.preparingFinished()
                }
            }
        }
    }
    
    private func processPhotos() {
        let feedPhotoModels = photos.map { mapPhoto($0) }
        feedStateSubject.send(.photos(feedPhotoModels))
    }
    
    private func mapPhoto(_ photo: Photo) -> FeedPhotoCellModel {
        FeedPhotoCellModel(
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
        
        if photos.isEmpty {
            feedStateSubject.send(.empty(
                title: "Something went wrong",
                subtitle: "Unable to load photos"
            ))
            return
        }
        
        if currentError?.localizedDescription == error.localizedDescription {
            return
        }
        
        currentError = error
        
        guard let networkError = error as? NetworkError else { return }
        
        if case .cancelled = networkError {
            currentError = nil
            return
        }
        
        let banner: Banner
        if case .clientError(let code) = networkError, code == 403 {
            banner = Banner(
                title: "The request limit has been reached",
                subtitle: "Requests are updated at the beginning of each hour",
                type: .error
            )
        } else {
            banner = Banner(
                title: "Network error",
                subtitle: "Please check your connection",
                type: .error
            )
        }
        
        if let bannerPresenter {
            DispatchQueue.main.async {
                bannerPresenter.presentBanner(banner)
            }
        } else {
            bannerSubject.send(banner)
        }
    }
}
