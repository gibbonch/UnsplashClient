import Foundation

struct UserDTO: Decodable {
    
    struct ProfileImageDTO: Decodable {
        let small: String
        let medium: String
        let large: String
    }
    
    let id: String
    let username: String
    let firstName: String
    let lastName: String?
    let profileImage: ProfileImageDTO
}
