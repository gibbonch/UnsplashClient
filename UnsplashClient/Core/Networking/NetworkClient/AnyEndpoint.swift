import Foundation

struct AnyEndpoint<T: ResponseType>: Endpoint {
    typealias Response = T
    
    let path: String
    let method: HTTPMethod
    let params: Params
    let headers: Headers
    let body: Data?
    
    init(
        path: String,
        method: HTTPMethod = .get,
        params: Params = [:],
        headers: Headers = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.params = params
        self.headers = headers
        self.body = body
    }
}

struct EndpointBuilder {
    
    private var path: String = ""
    private var method: HTTPMethod = .get
    private var params: Params = [:]
    private var headers: Headers = [:]
    private var body: Data?
    
    func path(_ path: String) -> EndpointBuilder {
        var builder = self
        builder.path = path
        return builder
    }
    
    func method(_ method: HTTPMethod) -> EndpointBuilder {
        var builder = self
        builder.method = method
        return builder
    }
    
    func get() -> EndpointBuilder {
        return method(.get)
    }
    
    func post() -> EndpointBuilder {
        return method(.post)
    }
    
    func put() -> EndpointBuilder {
        return method(.put)
    }
    
    func patch() -> EndpointBuilder {
        return method(.patch)
    }
    
    func delete() -> EndpointBuilder {
        return method(.delete)
    }
    
    func params(_ params: Params) -> EndpointBuilder {
        var builder = self
        builder.params = params
        return builder
    }
    
    func addParam(key: String, value: String) -> EndpointBuilder {
        var builder = self
        builder.params[key] = value
        return builder
    }
    
    func addParam(key: String, value: Int) -> EndpointBuilder {
        return addParam(key: key, value: String(value))
    }
    
    func addParam(key: String, value: Double) -> EndpointBuilder {
        return addParam(key: key, value: String(value))
    }
    
    func addParam(key: String, value: Bool) -> EndpointBuilder {
        return addParam(key: key, value: String(value))
    }
    
    
    func headers(_ headers: Headers) -> EndpointBuilder {
        var builder = self
        builder.headers = headers
        return builder
    }
    
    func addHeader(key: String, value: String) -> EndpointBuilder {
        var builder = self
        builder.headers[key] = value
        return builder
    }
    
    func contentType(_ contentType: String) -> EndpointBuilder {
        return addHeader(key: "Content-Type", value: contentType)
    }
    
    func accept(_ accept: String) -> EndpointBuilder {
        return addHeader(key: "Accept", value: accept)
    }
    
    func authorization(_ auth: String) -> EndpointBuilder {
        return addHeader(key: "Authorization", value: auth)
    }
    
    func bearerToken(_ token: String) -> EndpointBuilder {
        return authorization("Bearer \(token)")
    }
    
    func body(_ body: Data) -> EndpointBuilder {
        var builder = self
        builder.body = body
        return builder
    }
    
    func build<T: ResponseType>() -> AnyEndpoint<T> {
        return AnyEndpoint(
            path: path,
            method: method,
            params: params,
            headers: headers,
            body: body
        )
    }
}
