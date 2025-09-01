import Foundation

protocol RequestBuilderProtocol {
    func buildRequest(
        endpoint: any Endpoint,
        cachePolicy: URLRequest.CachePolicy,
        timeoutInterval: TimeInterval,
        middlewareChain: MiddlewareChain
    ) throws -> URLRequest
}

final class RequestBuilder: RequestBuilderProtocol {
    private let configuration: NetworkClientConfiguration
    
    init(configuration: NetworkClientConfiguration) {
        self.configuration = configuration
    }
    
    func buildRequest(
        endpoint: any Endpoint,
        cachePolicy: URLRequest.CachePolicy,
        timeoutInterval: TimeInterval,
        middlewareChain: MiddlewareChain
    ) throws -> URLRequest {
        
        let url = try buildURL(for: endpoint)
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        
        configureRequest(&request, with: endpoint)
        
        return middlewareChain.processRequest(request)
    }
    
    private func buildURL(for endpoint: any Endpoint) throws -> URL {
        guard var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL(configuration.baseURL.absoluteString)
        }
        
        components.path = endpoint.path
        components.queryItems = endpoint.params.map { name, value in
            URLQueryItem(name: name, value: value.description)
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL(components.description)
        }
        
        return url
    }
    
    private func configureRequest(_ request: inout URLRequest, with endpoint: any Endpoint) {
        request.httpMethod = endpoint.method.rawValue
        
        for header in endpoint.headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        request.httpBody = endpoint.body
    }
}
