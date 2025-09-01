import Foundation

final class NetworkClient {
    
    private let configuration: NetworkClientConfiguration
    private let session: URLSession
    private let middlewareChain: MiddlewareChain
    private let requestBuilder: RequestBuilderProtocol
    private let responseProcessor: ResponseProcessorProtocol
    
    init(
        configuration: NetworkClientConfiguration,
        middlewareChain: MiddlewareChain = MiddlewareChain(),
        requestBuilder: RequestBuilderProtocol? = nil,
        responseProcessor: ResponseProcessorProtocol? = nil
    ) {
        self.configuration = configuration
        self.session = URLSession(configuration: configuration.sessionConfiguration)
        self.middlewareChain = middlewareChain
        self.requestBuilder = requestBuilder ?? RequestBuilder(configuration: configuration)
        self.responseProcessor = responseProcessor ?? ResponseProcessor(decoder: configuration.decoder)
    }
    
    convenience init(
        baseURL: URL,
        config: URLSessionConfiguration = .default,
        middlewareChain: MiddlewareChain = MiddlewareChain()
    ) {
        let configuration = NetworkClientConfiguration(baseURL: baseURL, sessionConfiguration: config)
        self.init(configuration: configuration, middlewareChain: middlewareChain)
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

// MARK: - CancellableTask Protocol

protocol CancellableTask {
    func cancel()
}

extension URLSessionTask: CancellableTask { }
