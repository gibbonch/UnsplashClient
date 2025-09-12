import Foundation

struct SearchPhotosEndpoint: Endpoint {
    typealias Response = PhotosSearchResultDTO
    
    let path: String = "/search/photos"
    let method: HTTPMethod = .get
    let headers: Headers = [:]
    let body: Data? = nil
    let params: Params
    
    init(searchQuery: SearchQuery) {
        var params: Params = searchQuery.filters.reduce(into: [:]) { result, filter in
            if let value = filter.value {
                result[filter.type.rawValue] = value
            }
        }
        params["query"] = searchQuery.text
        self.params = params
    }
}
