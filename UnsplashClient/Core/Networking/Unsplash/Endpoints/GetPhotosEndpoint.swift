import Foundation

struct GetPhotosEndpoint: Endpoint {
    
    typealias Response = PhotosDTO
    
    let path: String
    let method: HTTPMethod
    let params: Params
    let headers: Headers
    let body: Data?
    
    init(page: Int = 1, perPage: Int = 10) {
        path = "/photos"
        method = HTTPMethod.get
        params = ["page": page.description, "per_page": perPage.description]
        headers = [:]
        body = nil
    }
}
