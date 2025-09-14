import Foundation
import Combine

protocol PhotoDetailViewModelProtocol {
    var photoDetail: AnyPublisher<PhotoDetailViewUIModel?, Never> { get }
    var isLiked: AnyPublisher<Bool, Never> { get }
    func favoriteButtonTapped()
    func imageLoadingFailed()
}

protocol PhotoDetailNavigationResponder: AnyObject {
    func dismissScene()
}

final class PhotoDetailViewModel: PhotoDetailViewModelProtocol {
    
    weak var responder: PhotoDetailNavigationResponder?
    
    var photoDetail: AnyPublisher<PhotoDetailViewUIModel?, Never> {
        photoDetailSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var isLiked: AnyPublisher<Bool, Never> {
        isLikedSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private let service: PhotoDetailServiceProtocol
    
    private let id: String
    private var photo: Photo?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter
    }()
    private let photoDetailSubject: CurrentValueSubject<PhotoDetailViewUIModel?, Never> = .init(nil)
    private let isLikedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    
    init(id: String, service: PhotoDetailServiceProtocol) {
        self.id = id
        self.service = service
        
        fetchPhoto()
    }
    
    func favoriteButtonTapped() {
        guard let photo else { return }
        
        let isLiked = isLikedSubject.value
        if isLiked {
            service.unlikePhoto(with: id)
        } else {
            service.likePhoto(photo)
        }
        
        isLikedSubject.send(!isLiked)
    }
    
    func imageLoadingFailed() {
        DispatchQueue.main.async { [weak self] in
            self?.responder?.dismissScene()
        }
    }
    
    private func fetchPhoto() {
        service.fetchPhoto(with: id) { [weak self] result in
            switch result {
            case .success(let detailedPhoto):
                self?.photo = detailedPhoto.photo
                let formattedDate = self?.dateFormatter.string(from: detailedPhoto.photo.createdAt ?? Date()) ?? "Unknown"
                let model = PhotoDetailViewUIModel(
                    photo: detailedPhoto.source,
                    color: detailedPhoto.photo.color,
                    date: formattedDate,
                    resolution: detailedPhoto.photo.resolution
                )
                
                self?.isLikedSubject.send(detailedPhoto.isLiked)
                self?.photoDetailSubject.send(model)
                
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.responder?.dismissScene()
        }
    }
}
