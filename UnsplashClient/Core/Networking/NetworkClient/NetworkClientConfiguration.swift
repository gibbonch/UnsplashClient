import Foundation

struct NetworkClientConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration
    let cachePolicy: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    let decoder: JSONDecoder
    
    init(
        baseURL: URL,
        sessionConfiguration: URLSessionConfiguration = .default,
        cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        timeoutInterval: TimeInterval = 30,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.sessionConfiguration = sessionConfiguration
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }
}
