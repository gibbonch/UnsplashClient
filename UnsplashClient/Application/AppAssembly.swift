import Foundation

final class AppAssembly: AssemblyProtocol {
    
    func assemble(diContainer: DIContainerProtocol) {
        let networkClient = createNetworkClient()
        diContainer.register(for: NetworkClientProtocol.self, networkClient)
        diContainer.register(for: ContextProvider.self, CoreDataStack())
    }
    
    private func createNetworkClient() -> NetworkClientProtocol {
        let configuration = NetworkClientConfiguration(
            baseURL: UnsplashEnvironment.baseURL
        )
        
        let chain = MiddlewareChain.with(requestMiddlewares: [AuthorizationMiddleware()])
        
        return NetworkClient(configuration: configuration, middlewareChain: chain)
    }
}
