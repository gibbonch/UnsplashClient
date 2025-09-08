import UIKit

final class AppCoordinator: CoordinatorProtocol {
    
    private let window: UIWindow
    private let diContainer: DIContainerProtocol
    private let tabBarController: UITabBarController
    private var childCoordinators: [CoordinatorProtocol] = []
    
    init(window: UIWindow, diContainer: DIContainerProtocol) {
        self.window = window
        self.diContainer = diContainer
        tabBarController = ThemedTabBarController()
    }
    
    func start() {
        showSplash()
        setupTabBarController()
    }
    
    private func showSplash() {
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    private func setupTabBarController() {
        let homeNavigationController = createHomeNavigationController()
        let favoritesNavigationController = createFavoritesNavigationController()
        
        tabBarController.viewControllers = [
            homeNavigationController,
            favoritesNavigationController,
        ]
        
        childCoordinators.forEach { $0.start() }
    }
    
    private func createHomeNavigationController() -> UINavigationController {
        let homeNavigationController = ThemedNavigationController()
        homeNavigationController.tabBarItem = UITabBarItem(title: nil, image: .homeAsset, selectedImage: nil)
        
        let homeDIContainer = DIContainer()
        homeDIContainer.parent = diContainer
        
        PhotoFeedAssembly().assemble(diContainer: homeDIContainer)
        
        let homeCoordinator = HomeCoordinator(
            navigationController: homeNavigationController,
            diContainer: homeDIContainer
        )
        
        homeCoordinator.onFinishPrepare = { [weak self] in
            self?.showMainFlow()
        }
        
        childCoordinators.append(homeCoordinator)
        
        return homeNavigationController
    }
    
    private func createFavoritesNavigationController() -> UINavigationController {
        let favoritesNavigationController = ThemedNavigationController()
        favoritesNavigationController.tabBarItem = UITabBarItem(title: nil, image: .heartAsset, selectedImage: nil)
        
        let favoritesDIContainer = DIContainer()
        favoritesDIContainer.parent = diContainer
        let favoritesCoordinator = FavoritesCoordinator(
            navigationController: favoritesNavigationController,
            diContainer: favoritesDIContainer
        )
        childCoordinators.append(favoritesCoordinator)
        
        return favoritesNavigationController
    }
    
    private func showMainFlow() {
        window.rootViewController = tabBarController
    }
}
