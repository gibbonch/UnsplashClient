import Foundation

protocol ResponseMiddleware {
    func process(response: HTTPURLResponse, data: Data?, for request: URLRequest)
}
