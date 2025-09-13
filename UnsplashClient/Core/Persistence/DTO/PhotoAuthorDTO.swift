import Foundation
import CoreData

@objc(PhotoAuthorDTO)
public class PhotoAuthorDTO: NSManagedObject {
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<PhotoAuthorDTO> {
        return NSFetchRequest<PhotoAuthorDTO>(entityName: "PhotoAuthorDTO")
    }
    
    @NSManaged public var identifier: String?
    @NSManaged public var nickname: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var small: String?
    @NSManaged public var medium: String?
    @NSManaged public var large: String?
    
    @NSManaged public var photos: NSSet?
    
    convenience init(user: User, context: NSManagedObjectContext) {
        self.init(context: context)
        
        identifier = user.id
        nickname = user.nickname
        firstName = user.firstName
        lastName = user.lastName
        small = user.profileImage.small.absoluteString
        medium = user.profileImage.medium.absoluteString
        large = user.profileImage.large.absoluteString
    }
    
    func mapToDomain() -> User? {
        guard let identifier,
              let nickname,
              let small, let smallURL = URL(string: small),
              let medium, let mediumURL = URL(string: medium),
              let large, let largeURL = URL(string: large) else {
            return nil
        }
        
        let profileImage = User.ProfileImage(small: smallURL, medium: mediumURL, large: largeURL)
        return User(id: identifier, nickname: nickname, firstName: firstName, lastName: lastName, profileImage: profileImage)
    }
}

extension PhotoAuthorDTO {
    
    static func create(for user: User, context: NSManagedObjectContext) -> PhotoAuthorDTO {
        let request = PhotoAuthorDTO.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PhotoAuthorDTO.identifier), user.id)
        
        if let existingAuthor = try? context.fetch(request).first {
            return existingAuthor
        }
        
        return PhotoAuthorDTO(user: user, context: context)
    }
}

extension PhotoAuthorDTO {
    
    @objc(addPhotosObject:)
    @NSManaged func addToPhotos(_ value: DetailedPhotoDTO)
    
    @objc(removePhotosObject:)
    @NSManaged func removeFromPhotos(_ value: DetailedPhotoDTO)
    
    @objc(addPhotos:)
    @NSManaged func addToPhotos(_ values: NSSet)
    
    @objc(removePhotos:)
    @NSManaged func removeFromPhotos(_ values: NSSet)
}

extension PhotoAuthorDTO: Identifiable { }
