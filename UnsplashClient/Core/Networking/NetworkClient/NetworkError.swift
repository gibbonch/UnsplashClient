import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL(String)
    
    case timeout
    case cancelled
    case noConnection
    case transportError(Error)
    
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    
    case invalidData
    case decodingError(Error)
    
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .transportError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received from server"
        case .clientError(let statusCode):
            return "Client error \(statusCode)"
        case .serverError(let statusCode):
            return "Server error \(statusCode)"
        case .invalidData:
            return "Invalid data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request was cancelled"
        case .noConnection:
            return "No connection"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
