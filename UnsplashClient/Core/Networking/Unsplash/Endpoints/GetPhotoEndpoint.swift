import Foundation

struct GetPhotoEndpoint: Endpoint {
    
    typealias Response = PhotoDTO
    
    let path: String
    let method: HTTPMethod
    let params: Params
    let headers: Headers
    let body: Data?
    
    init(id: String) {
        path = "/photos/\(id)"
        method = HTTPMethod.get
        params = [:]
        headers = [:]
        body = nil
    }
}
