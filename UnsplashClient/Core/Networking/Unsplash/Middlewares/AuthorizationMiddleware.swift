import Foundation

struct AuthorizationMiddleware: RequestMiddleware {
    
    func process(request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("Client-ID \(UnsplashEnvironment.accessKey)", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }
}
