import UIKit

final class HomeCoordinator: CoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private let diContainer: DIContainerProtocol
    
    private let rootViewController: HomeViewController
    private let photoFeedViewController: UIViewController
    private var searchViewController: UIViewController?
    
    init(navigationController: UINavigationController, diContainer: DIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        
        rootViewController = HomeViewController()
        photoFeedViewController = PhotoFeedViewController()
        
        rootViewController.delegate = self
    }
    
    func start() {
        navigationController.setViewControllers([rootViewController], animated: false)
        
        rootViewController.addChild(photoFeedViewController)
        rootViewController.view.addSubview(photoFeedViewController.view)
        photoFeedViewController.view.frame = rootViewController.view.frame
        photoFeedViewController.didMove(toParent: rootViewController)
    }
    
    func showFeed() {
        searchViewController?.willMove(toParent: nil)
        searchViewController?.removeFromParent()
        searchViewController?.view.removeFromSuperview()
        searchViewController = nil
    }
    
    func showDetail() {
        
    }
    
    func showSearch() {
        let searchViewController = SearchViewController()
        rootViewController.addChild(searchViewController)
        rootViewController.view.addSubview(searchViewController.view)
        searchViewController.view.frame = rootViewController.view.frame
        searchViewController.didMove(toParent: rootViewController)
        
        self.searchViewController = searchViewController
    }
}

// MARK: - HomeNavigationResponder

extension HomeCoordinator: HomeNavigationResponder {
    
    func homeViewControllerDidStartSearch(_ vc: HomeViewController) {
        showSearch()
    }
    
    func homeViewControllerDidEndSearch(_ vc: HomeViewController) {
        showFeed()
    }
}
