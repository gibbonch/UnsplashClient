import Foundation
import CoreData

@objc(DetailedPhotoDTO)
public class DetailedPhotoDTO: NSManagedObject {
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<DetailedPhotoDTO> {
        return NSFetchRequest<DetailedPhotoDTO>(entityName: "DetailedPhotoDTO")
    }
    
    @NSManaged public var identifier: String?
    @NSManaged public var raw: String?
    @NSManaged public var full: String?
    @NSManaged public var regular: String?
    @NSManaged public var small: String?
    @NSManaged public var thumb: String?
    @NSManaged public var width: Int64
    @NSManaged public var height: Int64
    @NSManaged public var createdAt: Date?
    @NSManaged public var color: String?
    @NSManaged public var photoDescription: String?
    
    @NSManaged public var timestamp: Date?
    
    @NSManaged public var author: PhotoAuthorDTO?
    
    @discardableResult
    convenience init(photo: Photo, context: NSManagedObjectContext) {
        self.init(context: context)
        
        identifier = photo.id
        raw = photo.urls.raw.absoluteString
        full = photo.urls.full.absoluteString
        regular = photo.urls.regular.absoluteString
        small = photo.urls.small.absoluteString
        thumb = photo.urls.thumb.absoluteString
        width = Int64(photo.resolution.width)
        height = Int64(photo.resolution.height)
        createdAt = photo.createdAt
        color = photo.color
        photoDescription = photo.description
        
        timestamp = Date()
        
        author = PhotoAuthorDTO.create(for: photo.author, context: context)
    }
    
    func mapToDomain(source: PhotoSource) -> DetailedPhoto? {
        guard let identifier = identifier,
              let rawString = raw, let rawURL = URL(string: rawString),
              let fullString = full, let fullURL = URL(string: fullString),
              let regularString = regular, let regularURL = URL(string: regularString),
              let smallString = small, let smallURL = URL(string: smallString),
              let thumbString = thumb, let thumbURL = URL(string: thumbString),
              let color,
              let author = author?.mapToDomain() else {
            return nil
        }
        
        let urls = Photo.URLs(
            raw: rawURL,
            full: fullURL,
            regular: regularURL,
            small: smallURL,
            thumb: thumbURL
        )
        
        let resolution = Photo.Resolution(
            width: Int(width),
            height: Int(height)
        )
        
        let photo = Photo(
            id: identifier,
            urls: urls,
            author: author,
            createdAt: createdAt,
            resolution: resolution,
            color: color,
            description: photoDescription
        )
        
        return DetailedPhoto(
            photo: photo,
            isLiked: true,
            source: source
        )
    }
}

extension DetailedPhotoDTO: Identifiable { }
