import UIKit

final class FavoritesCoordinator: CoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let diContainer: DIContainerProtocol
    
    init(navigationController: UINavigationController, diContainer: DIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        showFavorites()
    }
    
    func showFavorites() {
        let favoritesViewController = FavoritesViewController()
        favoritesViewController.tabBarItem = UITabBarItem(title: nil, image: .heartAsset, selectedImage: nil)
        navigationController.setViewControllers([favoritesViewController], animated: false)
    }
}
