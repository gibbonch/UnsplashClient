import Foundation

final class AppAssembly: AssemblyProtocol {
    
    func assemble(diContainer: DIContainerProtocol) {
        let networkClient = createNetworkClient()
        let coreDataStack = CoreDataStack()
        diContainer.register(for: NetworkClientProtocol.self, networkClient)
        diContainer.register(for: ContextProvider.self, coreDataStack)
        diContainer.register(for: PhotoRepositoryProtocol.self, PhotoRepository(client: networkClient))
        diContainer.register(for: FavoritesRepositoryProtocol.self, FavoritesRepository(contextProvider: coreDataStack))
    }
    
    private func createNetworkClient() -> NetworkClientProtocol {
        let memoryCapacity = 25 * 1024 * 1024
        let diskCapacity = 250 * 1024 * 1024
        
        let urlCache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
        )
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = urlCache
        sessionConfiguration.requestCachePolicy = .useProtocolCachePolicy
        sessionConfiguration.timeoutIntervalForRequest = 5
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
#if DEBUG
        // swiftlint:disable all
        let rateLimitMiddleware = RateLimitMiddleware {
            print("Rate limit: \($0.remain)/\($0.limit)")
        }
        // swiftlint:enable all
        let chain = MiddlewareChain.with(
            requestMiddlewares: [AuthorizationMiddleware()],
            responseMiddlewares: [rateLimitMiddleware]
        )
#else
        let chain = MiddlewareChain.with(requestMiddlewares: [AuthorizationMiddleware()])
#endif
        
        return NetworkClient(
            baseURL: UnsplashEnvironment.baseURL,
            configuration: sessionConfiguration,
            decoder: decoder,
            middlewareChain: chain
        )
    }
}
