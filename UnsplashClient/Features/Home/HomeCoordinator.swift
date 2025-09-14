import UIKit

final class HomeCoordinator: CoordinatorProtocol {
    
    var onFinishPrepare: (() -> Void)?
    
    private let navigationController: UINavigationController
    private let diContainer: DIContainerProtocol
    
    private let homeViewController: HomeViewController
    private let homeViewModel: HomeViewModel
    
    private var searchViewController: UIViewController?
    
    private var isSearching = false
    
    init(navigationController: UINavigationController, diContainer: DIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        
        homeViewModel = HomeViewModel()
        homeViewController = HomeViewController(viewModel: homeViewModel)
        homeViewModel.responder = self
    }
    
    func start() {
        navigationController.setViewControllers([homeViewController], animated: false)
        showPhotosFeed()
    }
    
    private func showPhotosFeed() {
        let useCase = diContainer.resolve(FetchPhotosUseCaseProtocol.self)!
        let viewModel = PhotoFeedViewModel(fetchPhotosUseCase: useCase)
        viewModel.responder = self
        viewModel.bannerPresenter = homeViewController
        let photoFeedViewController = PhotoFeedViewController(viewModel: viewModel)
        
        addChild(photoFeedViewController, on: homeViewController)
    }
    
    private func showSearchResults(for query: SearchQuery) {
        let useCase = diContainer.resolve(FetchPhotosUseCaseProtocol.self)!
        let viewModel = PhotoFeedViewModel(fetchPhotosUseCase: useCase, searchQuery: query)
        viewModel.responder = self
        viewModel.bannerPresenter = homeViewController
        let photoFeedViewController = PhotoFeedViewController(viewModel: viewModel)
        
        photoFeedViewController.navigationItem.title = query.text
        navigationController.pushViewController(photoFeedViewController, animated: true)
    }
    
    private func showPhotoDetail(with id: String) {
        let service = diContainer.resolve(PhotoDetailServiceProtocol.self)!
        let viewModel = PhotoDetailViewModel(id: id, service: service)
        viewModel.responder = self
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showSearch() {
        guard !isSearching else { return }
        
        let searchRepository = diContainer.resolve(SearchRepositoryProtocol.self)!
        let recentQueriesRepository = diContainer.resolve(RecentQueriesRepositoryProtocol.self)!
        
        let viewModel = SearchViewModel(
            searchRepository: searchRepository,
            recentQueriesRepository: recentQueriesRepository
        )
        viewModel.bannerPresenter = homeViewController
        viewModel.searchBarOwner = homeViewController
        viewModel.responder = self
        
        let searchViewController = SearchViewController(viewModel: viewModel)
        self.searchViewController = searchViewController
        searchViewController.hideKeyboardResponder = homeViewController
        homeViewModel.searchDelegate = viewModel
        addChild(searchViewController, on: homeViewController)
        isSearching = true
    }
    
    private func stopSearch() {
        homeViewModel.searchDelegate = nil
        searchViewController?.willMove(toParent: nil)
        searchViewController?.removeFromParent()
        searchViewController?.view.removeFromSuperview()
        searchViewController = nil
        isSearching = false
    }
    
    private func addChild(_ childVC: UIViewController, on parentVC: UIViewController) {
        parentVC.addChild(childVC)
        parentVC.view.addSubview(childVC.view)
        childVC.view.frame = parentVC.view.frame
        childVC.didMove(toParent: parentVC)
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
    
    func routeToDetail(with id: String) {
        showPhotoDetail(with: id)
    }
    
    func preparingFinished() {
        onFinishPrepare?()
    }
}

// MARK: - SearchNavigationResponder

extension HomeCoordinator: SearchNavigationResponder {
    
    func routeToSearchResults(with query: SearchQuery) {
        showSearchResults(for: query)
    }
}

// MARK: - PhotoDetailNavigationResponder

extension HomeCoordinator: PhotoDetailNavigationResponder {
    
    func dismissScene() {
        navigationController.popViewController(animated: true)
        
        if let presenter = navigationController as? BannerPresenting {
            let banner = Banner(title: "Something went wrong", type: .error)
            presenter.showBanner(banner)
        }
    }
}
