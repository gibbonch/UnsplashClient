import Foundation

struct User {
    
    struct ProfileImage {
        let small: URL
        let medium: URL
        let large: URL
    }
    
    let id: String
    let nickname: String
    let firstName: String?
    let lastName: String?
    let profileImage: ProfileImage
}
