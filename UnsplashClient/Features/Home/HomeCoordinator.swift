import UIKit

final class HomeCoordinator: CoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let diContainer: DIContainerProtocol
    
    private let homeViewController: HomeViewController
    
    init(navigationController: UINavigationController, diContainer: DIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        homeViewController = HomeViewController()
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: .homeAsset, selectedImage: nil)
    }
    
    func start() {
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func showFeed() {
        
    }
    
    func showDetail() {
        
    }
    
    func showSearch() {
        
    }
}
