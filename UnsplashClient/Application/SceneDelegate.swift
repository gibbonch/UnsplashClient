import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var appDIContainer: DIContainer?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let diContainer = DIContainer()
        AppAssembly().assemble(diContainer: diContainer)
        appDIContainer = diContainer
        
        guard let window else { return }
        
        ThemeManager.shared.setup(with: window)
        
        appCoordinator = AppCoordinator(window: window, diContainer: diContainer)
        appCoordinator?.start()
    }
}
