import UIKit

final class HomeCoordinator: CoordinatorProtocol {
    
    var onFinishPrepare: (() -> Void)?
    
    private let navigationController: UINavigationController
    private let diContainer: DIContainerProtocol
    
    private let homeViewController: HomeViewController
    private var searchViewController: UIViewController?
    
    private var isSearching = false
    
    init(navigationController: UINavigationController, diContainer: DIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        
        let homeViewModel = HomeViewModel()
        homeViewController = HomeViewController(viewModel: homeViewModel)
        homeViewModel.responder = self
    }
    
    func start() {
        navigationController.setViewControllers([homeViewController], animated: false)
        showPhotosFeed()
    }
    
    private func showPhotosFeed(with query: SearchQuery? = nil) {
        let useCase = diContainer.resolve(FetchPhotosUseCaseProtocol.self)!
        let viewModel = PhotoFeedViewModel(fetchPhotosUseCase: useCase)
        viewModel.responder = self
        let photoFeedViewController = PhotoFeedViewController(viewModel: viewModel)
        
        homeViewController.addChild(photoFeedViewController)
        homeViewController.view.addSubview(photoFeedViewController.view)
        photoFeedViewController.view.frame = homeViewController.view.frame
        photoFeedViewController.didMove(toParent: homeViewController)
    }
    
    private func showPhotoDetail() {
        
    }
    
    private func showSearch() {
        guard !isSearching else { return }
        
        let searchViewController = SearchViewController()
        searchViewController.hideKeyboardResponder = homeViewController
        homeViewController.addChild(searchViewController)
        homeViewController.view.addSubview(searchViewController.view)
        searchViewController.view.frame = homeViewController.view.frame
        searchViewController.didMove(toParent: homeViewController)
        
        self.searchViewController = searchViewController
        isSearching = true
    }
    
    private func stopSearch() {
        searchViewController?.willMove(toParent: nil)
        searchViewController?.removeFromParent()
        searchViewController?.view.removeFromSuperview()
        searchViewController = nil
        isSearching = false
    }
}

// MARK: - HomeNavigationResponder

extension HomeCoordinator: HomeNavigationResponder {
    
    func startSearchFlow() {
        showSearch()
    }
    
    func stopSearchFlow() {
        stopSearch()
    }
}

// MARK: - PhotoFeedNavigationResponder

extension HomeCoordinator: PhotoFeedNavigationResponder {
    
    func routeToDetail(with id: String) { }
    
    func preparingFinished() {
        onFinishPrepare?()
    }
}
