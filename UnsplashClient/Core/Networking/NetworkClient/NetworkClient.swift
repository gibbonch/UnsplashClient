import Foundation

final class NetworkClient {
    
    private let configuration: NetworkClientConfiguration
    private let session: URLSession
    private let middlewareChain: MiddlewareChain
    private let requestBuilder: RequestBuilder
    private let responseProcessor: ResponseProcessor
    
    init(configuration: NetworkClientConfiguration, middlewareChain: MiddlewareChain = MiddlewareChain()) {
        self.configuration = configuration
        self.session = URLSession(configuration: configuration.sessionConfiguration)
        self.middlewareChain = middlewareChain
        self.requestBuilder = RequestBuilder(configuration: configuration)
        self.responseProcessor = ResponseProcessor(decoder: configuration.decoder)
    }
    
    @discardableResult
    func request<T: Endpoint>(
        endpoint: T,
        cachePolicy: URLRequest.CachePolicy? = nil,
        timeoutInterval: TimeInterval? = nil,
        completion: @escaping (Result<T.Response, NetworkError>) -> Void
    ) -> CancellableTask? {
        
        let request: URLRequest
        do {
            request = try requestBuilder.buildRequest(
                endpoint: endpoint,
                cachePolicy: cachePolicy ?? configuration.cachePolicy,
                timeoutInterval: timeoutInterval ?? configuration.timeoutInterval,
                middlewareChain: middlewareChain
            )
        } catch let error as NetworkError {
            completion(.failure(error))
            return nil
        } catch {
            completion(.failure(.unknown))
            return nil
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            self?.middlewareChain.processResponse(httpResponse, data: data, for: request)
            
            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            self?.responseProcessor.processResponse(
                data: data,
                responseType: T.Response.self,
                completion: completion
            )
        }
        
        task.resume()
        return task
    }
}

// MARK: - Request Builder

final class RequestBuilder {
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

// MARK: - Response Processor

final class ResponseProcessor {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    func processResponse<T: ResponseType>(
        data: Data?,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(.invalidData))
            }
            return
        }
        
        do {
            let result = try decoder.decode(T.self, from: data)
            DispatchQueue.main.async {
                completion(.success(result))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.decodingError(error)))
            }
        }
    }
}

// MARK: - CancellableTask Protocol

protocol CancellableTask {
    func cancel()
}

extension URLSessionTask: CancellableTask { }
