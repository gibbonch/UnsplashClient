import UIKit

final class AppCoordinator: CoordinatorProtocol {
    
    private let window: UIWindow
    private let diContainer: DIContainerProtocol
    private let tabBarController: UITabBarController
    private var childCoordinators: [CoordinatorProtocol] = []
    
    init(window: UIWindow, diContainer: DIContainerProtocol) {
        self.window = window
        self.diContainer = diContainer
        tabBarController = UITabBarController()
    }
    
    func start() {
        showMainFlow()
    }
    
    private func showMainFlow() {
        let homeNavigationController = UINavigationController()
        let homeDIContainer = DIContainer()
        let homeCoordinator = HomeCoordinator(
            navigationController: homeNavigationController,
            diContainer: homeDIContainer
        )
        childCoordinators.append(homeCoordinator)
        
        let favoritesNavigationController = UINavigationController()
        let favoritesDIContainer = DIContainer()
        let favoritesCoordinator = FavoritesCoordinator(
            navigationController: favoritesNavigationController,
            diContainer: favoritesDIContainer
        )
        childCoordinators.append(favoritesCoordinator)
        
        tabBarController.viewControllers = [
            homeNavigationController,
            favoritesNavigationController,
        ]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        homeCoordinator.start()
        favoritesCoordinator.start()
        
        
    }
}
