import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var client: NetworkClient!

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        
        let chain = MiddlewareChain.with(
            requestMiddlewares: [AuthorizationMiddleware()],
            responseMiddlewares: [RateLimitMiddleware { print("\($0.remain)/\($0.limit)") }]
        )
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let config = NetworkClientConfiguration(baseURL: UnsplashEnvironment.baseURL, decoder: decoder)
        
        client = NetworkClient(configuration: config, middlewareChain: chain)
        
        let endpoint = GetPhotoEndpoint(id: "g96HjSzemvU")
        client.request(endpoint: endpoint) { result in
            switch result {
            case .success(let photos):
                print(photos)
            case .failure(let error):
                if case .decodingError(let error) = error {
                    print(error)
                }
            }
        }
    }
}
