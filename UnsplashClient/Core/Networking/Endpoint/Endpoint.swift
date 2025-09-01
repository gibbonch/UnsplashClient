import Foundation

protocol Endpoint {
    associatedtype Response: ResponseType
    var path: String { get }
    var method: HTTPMethod { get }
    var params: Params { get }
    var headers: Headers { get }
    var body: Data? { get }
}

typealias Params = [String: String]
typealias Headers = [String: String]

protocol ResponseType: Decodable { }

extension Array: ResponseType where Element: ResponseType { }



