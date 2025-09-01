import Foundation

protocol MiddlewareChainProtocol {
    func addRequestMiddleware(_ middleware: RequestMiddleware)
    func addResponseMiddleware(_ middleware: ResponseMiddleware)
    func processRequest(_ request: URLRequest) -> URLRequest
    func processResponse(_ response: HTTPURLResponse, data: Data?, for request: URLRequest)
}

final class MiddlewareChain: MiddlewareChainProtocol {
    
    private var requestMiddlewares: [RequestMiddleware] = []
    private var responseMiddlewares: [ResponseMiddleware] = []
    
    func addRequestMiddleware(_ middleware: RequestMiddleware) {
        requestMiddlewares.append(middleware)
    }
    
    func addResponseMiddleware(_ middleware: ResponseMiddleware) {
        responseMiddlewares.append(middleware)
    }
    
    func processRequest(_ request: URLRequest) -> URLRequest {
        var currentRequest = request
        
        for middleware in requestMiddlewares {
            currentRequest = middleware.process(request: currentRequest)
        }
        
        return currentRequest
    }
    
    func processResponse(_ response: HTTPURLResponse, data: Data?, for request: URLRequest) {
        for middleware in responseMiddlewares {
            middleware.process(response: response, data: data, for: request)
        }
    }
}

extension MiddlewareChain {
    
    static func with(requestMiddlewares: [RequestMiddleware], responseMiddlewares: [ResponseMiddleware]) -> MiddlewareChain {
        let chain = MiddlewareChain()
        requestMiddlewares.forEach { chain.addRequestMiddleware($0) }
        responseMiddlewares.forEach { chain.addResponseMiddleware($0) }
        return chain
    }
}
