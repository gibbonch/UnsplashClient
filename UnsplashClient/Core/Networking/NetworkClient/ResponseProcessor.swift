import Foundation

protocol ResponseProcessorProtocol {
    func processResponse<T: ResponseType>(
        data: Data?,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

final class ResponseProcessor: ResponseProcessorProtocol {
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
                completion(.failure(.noData))
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
