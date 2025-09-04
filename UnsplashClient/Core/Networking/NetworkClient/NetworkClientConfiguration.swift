import Foundation

struct NetworkClientConfiguration {
    let baseURL: URL
    let sessionConfiguration: URLSessionConfiguration
    let timeoutInterval: TimeInterval
    let decoder: JSONDecoder
    
    init(
        baseURL: URL,
        sessionConfiguration: URLSessionConfiguration = .default,
        timeoutInterval: TimeInterval = 30,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.sessionConfiguration = sessionConfiguration
        self.timeoutInterval = timeoutInterval
        self.decoder = decoder
    }
}
