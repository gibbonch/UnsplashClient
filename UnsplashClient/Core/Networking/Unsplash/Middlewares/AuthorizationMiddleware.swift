import Foundation

final class AuthorizationMiddleware: RequestMiddleware {
    
    func process(request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }
}
