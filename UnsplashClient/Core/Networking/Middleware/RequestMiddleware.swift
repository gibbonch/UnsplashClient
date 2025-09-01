import Foundation

protocol RequestMiddleware {
    func process(request: URLRequest) -> URLRequest
}



