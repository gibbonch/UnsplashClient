import Foundation

protocol NetworkClientProtocol {
    
    @discardableResult
    func request<T: Endpoint>(
        endpoint: T,
        completion: @escaping (Result<T.Response, NetworkError>) -> Void
    ) -> CancellableTask?
    
    @discardableResult
    func request<T: Endpoint>(
        endpoint: T,
        cachePolicy: URLRequest.CachePolicy,
        timeoutInterval: TimeInterval,
        completion: @escaping (Result<T.Response, NetworkError>) -> Void
    ) -> CancellableTask?
}

final class NetworkClient: NetworkClientProtocol {
    
    // MARK: - Private Properties
    
    private let session: URLSession
    private let baseURL: URL
    
    private let decoder: JSONDecoder
    
    private let middlewareChain: MiddlewareChainProtocol
    
    // MARK: - Lifecycle
    
    init(
        baseURL: URL,
        configuration: URLSessionConfiguration = .default,
        decoder: JSONDecoder = JSONDecoder(),
        middlewareChain: MiddlewareChainProtocol = MiddlewareChain()
    ) {
        self.baseURL = baseURL
        session = URLSession(configuration: configuration)
        self.decoder = decoder
        self.middlewareChain = middlewareChain
    }
    
    // MARK: - Internal Methods
    
    @discardableResult
    func request<T: Endpoint>(endpoint: T, completion: @escaping (Result<T.Response, NetworkError>) -> Void) -> CancellableTask? {
        request(
            endpoint: endpoint,
            cachePolicy: session.configuration.requestCachePolicy,
            timeoutInterval: session.configuration.timeoutIntervalForRequest,
            completion: completion
        )
    }
    
    @discardableResult
    func request<T: Endpoint>(
        endpoint: T,
        cachePolicy: URLRequest.CachePolicy,
        timeoutInterval: TimeInterval,
        completion: @escaping (Result<T.Response, NetworkError>) -> Void
    ) -> CancellableTask? {
        
        let request: URLRequest
        do {
            request = try buildRequest(for: endpoint, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        } catch {
            completion(.failure(error as? NetworkError ?? .unknown))
            return nil
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else {
                completion(.failure(.unknown))
                return
            }
            
            if let networkError = mapToNetworkError(error) {
                completion(.failure(networkError))
                return
            }
            
            do {
                try validateResponse(response)
                
                guard let data else {
                    completion(.failure(.invalidData))
                    return
                }
                
                let dto = try decoder.decode(T.Response.self, from: data)
                completion(.success(dto))
                
            } catch let error as NetworkError {
                completion(.failure(error))
            } catch let error as DecodingError {
                completion(.failure(.decodingError(error)))
            } catch {
                completion(.failure(.unknown))
            }
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Private Methods
    
    private func buildRequest(for endpoint: any Endpoint, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval) throws -> URLRequest {
        let url = try buildURL(for: endpoint)
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        endpoint.headers.forEach { key, value in
            if !key.isEmpty, !value.isEmpty {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let processedRequest = middlewareChain.processRequest(request)
        
        return processedRequest
    }
    
    private func buildURL(for endpoint: any Endpoint) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL(baseURL.absoluteString)
        }
        
        components.path = endpoint.path
        
        components.queryItems = endpoint.params
            .filter { key, value in !key.isEmpty && !value.isEmpty }
            .map { key, value in URLQueryItem(name: key, value: value) }
        
        guard let url = components.url else {
            let errorDescription = "Failed to construct URL from components: \(components)"
            throw NetworkError.invalidURL(errorDescription)
        }
        
        return url
    }
    
    private func mapToNetworkError(_ error: Error?) -> NetworkError? {
        guard let error else { return nil }
        guard let urlError = error as? URLError else { return .unknown}
        
        switch urlError.code {
        case .cancelled:
            return .cancelled
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .noConnection
        default:
            return .transportError(urlError)
        }
    }
    
    private func validateResponse(_ response: URLResponse?) throws {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        middlewareChain.processResponse(response)
        
        let statusCode = response.statusCode
        
        if (400...499).contains(statusCode) {
            throw NetworkError.clientError(statusCode)
        }
        
        if (500...599).contains(statusCode) {
            throw NetworkError.serverError(statusCode)
        }
    }
}

// MARK: - CancellableTask Protocol

protocol CancellableTask {
    func cancel()
}

extension URLSessionTask: CancellableTask { }
