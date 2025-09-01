import Foundation

struct RateLimitMiddleware: ResponseMiddleware {
    private let onRateLimitChange: ((RateLimit) -> Void)?
    
    init(onRateLimitChange: ((RateLimit) -> Void)? = nil) {
        self.onRateLimitChange = onRateLimitChange
    }
    
    func process(response: HTTPURLResponse, data: Data?, for request: URLRequest) {
        if let limitHeader = response.value(forHTTPHeaderField: "X-Ratelimit-Limit"),
           let remainingHeader = response.value(forHTTPHeaderField: "X-Ratelimit-Remaining"),
           let limit = Int(limitHeader),
           let remaining = Int(remainingHeader) {
            onRateLimitChange?(RateLimit(limit: limit, remain: remaining))
        }
    }
}

struct RateLimit {
    let limit: Int
    let remain: Int
}
