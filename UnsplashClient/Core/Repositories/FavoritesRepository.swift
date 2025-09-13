import Foundation
import CoreData
import Combine
import Kingfisher

protocol FavoritesRepositoryProtocol {
    func storeFavoritePhoto(_ photo: Photo)
    func deleteFavoritePhoto(with id: String)
    func fetchFavoritePhoto(with id: String, completion: @escaping (DetailedPhoto?) -> Void)
    func fetchFavoritePhotos(page: Int, perPage: Int, completion: @escaping ([DetailedPhoto]) -> Void)
}

final class FavoritesRepository: FavoritesRepositoryProtocol {
    
    private let contextProvider: ContextProvider
    private let photoStore: PhotoStoreProtocol
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = contextProvider.viewContext.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    init(contextProvider: ContextProvider, photoStore: PhotoStoreProtocol = PhotoStore()) {
        self.contextProvider = contextProvider
        self.photoStore = photoStore
    }
    
    func storeFavoritePhoto(_ photo: Photo) {
        backgroundContext.perform { [weak self] in
            guard let self, !hasPhotoStored(photo.id, context: backgroundContext) else { return }
            DetailedPhotoDTO(photo: photo, context: backgroundContext)
            photoStore.savePhoto(with: photo.id, url: photo.urls.regular)
            saveBackgroundContext()
        }
    }
    
    func deleteFavoritePhoto(with id: String) {
        backgroundContext.perform { [weak self] in
            guard let self, let dto = fetchPhoto(with: id, context: backgroundContext) else { return }
            backgroundContext.delete(dto)
            photoStore.deletePhoto(with: id)
            saveBackgroundContext()
        }
    }
    
    func fetchFavoritePhoto(with id: String, completion: @escaping (DetailedPhoto?) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self, let dto = fetchPhoto(with: id, context: backgroundContext) else {
                completion(nil)
                return
            }
            
            if let filePath = photoStore.imageFilePath(id: id),
               let photo = dto.mapToDomain(source: .local(filePath)) {
                completion(photo)
            } else {
                if let photo = dto.mapToDomain(source: .remote) {
                    completion(photo)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchFavoritePhotos(page: Int, perPage: Int, completion: @escaping ([DetailedPhoto]) -> Void) {
        backgroundContext.perform { [weak self] in
            guard let self else {
                completion([])
                return
            }
            
            do {
                let request = DetailedPhotoDTO.fetchRequest()
                request.fetchLimit = perPage
                request.fetchOffset = page * perPage
                request.sortDescriptors = [
                    NSSortDescriptor(key: #keyPath(DetailedPhotoDTO.timestamp), ascending: false)
                ]
                
                let dtos = try backgroundContext.fetch(request)
                
                let photos = dtos.compactMap { dto -> DetailedPhoto? in
                    guard let photoId = dto.identifier else { return nil }
                    
                    let source: PhotoSource
                    if let filePath = self.photoStore.imageFilePath(id: photoId) {
                        source = .local(filePath)
                    } else {
                        source = .remote
                    }
                    
                    return dto.mapToDomain(source: source)
                }
                
                completion(photos)
                
            } catch {
                completion([])
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func hasPhotoStored(_ id: String, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<DetailedPhotoDTO> = DetailedPhotoDTO.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(DetailedPhotoDTO.identifier), id)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    private func fetchPhoto(with id: String, context: NSManagedObjectContext) -> DetailedPhotoDTO? {
        let request = DetailedPhotoDTO.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(DetailedPhotoDTO.identifier), id)
        
        let dto = try? context.fetch(request).first
        return dto
    }
    
    private func saveBackgroundContext() {
        do {
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }
        } catch {
            backgroundContext.rollback()
        }
    }
}

// MARK: - PhotoImageStore

protocol PhotoStoreProtocol {
    func savePhoto(with id: String, url: URL)
    func deletePhoto(with id: String)
    func imageFilePath(id: String) -> URL?
}

final class PhotoStore: PhotoStoreProtocol {
    
    private let fileManager: FileManager
    private let kingfisherManager: KingfisherManager
    private let cache: ImageCache
    
    private let queue = DispatchQueue(label: "com.unsplash-client.photo-store", qos: .utility)
    
    private lazy var photosDirectory: URL = {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("FavoritePhotos")
        try? fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
        return photosPath
    }()
    
    init(
        fileManager: FileManager = .default,
        kingfisherManager: KingfisherManager = .shared,
        cache: ImageCache = .default
    ) {
        self.fileManager = fileManager
        self.kingfisherManager = kingfisherManager
        self.cache = cache
    }
    
    func savePhoto(with id: String, url: URL) {
        performSavePhoto(with: id, url: url)
    }
    
    func deletePhoto(with id: String) {
        queue.async { [weak self] in
            guard let self else { return }
            
            let filePath = photosDirectory.appendingPathComponent(id, conformingTo: .jpeg)
            
            if fileManager.fileExists(atPath: filePath.path) {
                try? fileManager.removeItem(at: filePath)
            }
        }
    }
    
    func imageFilePath(id: String) -> URL? {
        return queue.sync { [weak self] in
            guard let self else { return nil }
            
            let filePath = photosDirectory.appendingPathComponent(id, conformingTo: .jpeg)
            
            guard fileManager.fileExists(atPath: filePath.path) else { return nil }
            return filePath
        }
    }
    
    private func performSavePhoto(with id: String, url: URL) {
        let filePath = photosDirectory.appendingPathComponent(id, conformingTo: .jpeg)
        
        guard !fileManager.fileExists(atPath: filePath.path) else { return }
        
        cache.retrieveImage(forKey: url.absoluteString) { [weak self] result in
            switch result {
            case .success(let cacheResult):
                if let imageData = cacheResult.image?.jpegData(compressionQuality: 0.9) {
                    self?.writeImageData(imageData, to: filePath)
                } else {
                    self?.downloadImage(from: url, to: filePath)
                }
            case .failure:
                self?.downloadImage(from: url, to: filePath)
            }
        }
    }
    
    private func downloadImage(from url: URL, to filePath: URL) {
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            if case .success(let retrieveResult) = result,
               let imageData = retrieveResult.image.jpegData(compressionQuality: 0.9) {
                self?.writeImageData(imageData, to: filePath)
            }
        }
    }
    
    private func writeImageData(_ imageData: Data, to filePath: URL) {
        queue.async {
            do {
                try imageData.write(to: filePath, options: [.atomic, .noFileProtection])
            } catch {
                return
            }
        }
    }
}
