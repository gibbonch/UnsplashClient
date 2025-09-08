import Foundation

struct UserDTO: Decodable {
    
    struct ProfileImageDTO: Decodable {
        let small: String
        let medium: String
        let large: String
    }
    
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let profileImage: ProfileImageDTO
}

// MARK: - Mapping

extension User {
    init?(dto: UserDTO) {
        guard let mappedPhoto = ProfileImage(dto: dto.profileImage) else {
            return nil
        }
        
        id = dto.id
        nickname = dto.username
        firstName = dto.firstName
        lastName = dto.lastName
        profileImage = mappedPhoto
    }
}

extension User.ProfileImage {
    init?(dto: UserDTO.ProfileImageDTO) {
        guard let smallURL = URL(string: dto.small),
              let mediumURL = URL(string: dto.medium),
              let largeURL = URL(string: dto.large) else {
            return nil
        }
        small = smallURL
        medium = mediumURL
        large = largeURL
    }
}
