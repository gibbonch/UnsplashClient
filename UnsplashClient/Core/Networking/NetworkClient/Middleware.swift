import Foundation

protocol RequestMiddleware {
    func process(request: URLRequest) -> URLRequest
}

protocol ResponseMiddleware {
    func process(response: HTTPURLResponse, data: Data?, for request: URLRequest)
}
