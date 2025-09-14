import Foundation
import Combine

protocol FavoritesViewModelProtocol {
    var photos: AnyPublisher<[URL], Never> { get }
    var isRefreshing: AnyPublisher<Bool, Never> { get }
    func viewWillAppear()
    func willDisplayCell(at indexPath: IndexPath)
    func didSelectCell(at indexPath: IndexPath)
    func refresh()
}

protocol FavoritesNavigationResponder: AnyObject {
    func routeToDetail(id: String)
}

final class FavoritesViewModel: FavoritesViewModelProtocol {
    
    // MARK: - Internal Properties
    
    weak var responder: FavoritesNavigationResponder?
    
    var photos: AnyPublisher<[URL], Never> {
        photosSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isRefreshing: AnyPublisher<Bool, Never> {
        isRefreshingSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Propertes
    
    private let favoritesRepository: FavoritesRepositoryProtocol
    private let photosSubject: CurrentValueSubject<[URL], Never> = .init([])
    private let isRefreshingSubject: CurrentValueSubject<Bool, Never> = .init(false)
    
    private var detailedPhotos: [DetailedPhoto] = []
    private var page = 0
    private let perPage = 20
    private var isLoading = false
    private var hasMorePages = true
    
    // MARK: - Lifecycle
    
    init(favoritesRepository: FavoritesRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
    }
    
    // MARK: - Internal Properites
    
    func viewWillAppear() {
        loadPhotos(reset: true)
    }
    
    func didSelectCell(at indexPath: IndexPath) {
        guard indexPath.row < detailedPhotos.count else { return }
        let photo = detailedPhotos[indexPath.row]
        responder?.routeToDetail(id: photo.photo.id)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        let threshold = max(0, detailedPhotos.count - 5)
        if indexPath.row >= threshold && !isLoading && hasMorePages {
            loadPhotos(reset: false)
        }
    }
    
    func refresh() {
        loadPhotos(reset: true)
    }
    
    // MARK: - Private Methods
    
    private func loadPhotos(reset: Bool) {
        guard !isLoading else { return }
        
        isLoading = true
        
        if reset {
            page = 0
            detailedPhotos = []
            hasMorePages = true
        }
        
        favoritesRepository.fetchFavoritePhotos(page: page, perPage: perPage) { [weak self] photos in
            guard let self else { return }
            
            isLoading = false
            
            if reset {
                self.detailedPhotos = photos
            } else {
                self.detailedPhotos.append(contentsOf: photos)
            }
            
            hasMorePages = photos.count == perPage
            
            if !reset {
                self.page += 1
            }
            
            let photoUrls = detailedPhotos.compactMap { photo -> URL? in
                switch photo.source {
                case .local(let url):
                    return url
                case .remote(let url):
                    return url
                }
            }
            
            isRefreshingSubject.send(false)
            photosSubject.send(photoUrls)
        }
    }
}
