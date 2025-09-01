import Foundation

struct AnyEndpoint<T: ResponseType>: Endpoint {
    typealias Response = T
    
    let path: String
    let method: HTTPMethod
    let params: Params
    let headers: Headers
    let body: Data?
    
    init(
        path: String,
        method: HTTPMethod = .get,
        params: Params = [:],
        headers: Headers = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.params = params
        self.headers = headers
        self.body = body
    }
}
