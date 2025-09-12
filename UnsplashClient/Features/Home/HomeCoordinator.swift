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
        
        homeViewController.addChild(photoFeedViewController)
        homeViewController.view.addSubview(photoFeedViewController.view)
        photoFeedViewController.view.frame = homeViewController.view.frame
        photoFeedViewController.didMove(toParent: homeViewController)
    }
    
    private func showSearchResults(for query: SearchQuery) {
        
    }
    
    private func showPhotoDetail() {
        
    }
    
    private func showSearch() {
        guard !isSearching else { return }
        
        let searchRepository = diContainer.resolve(SearchRepositoryProtocol.self)!
        let contextProvider = diContainer.resolve(ContextProvider.self)!
        let recentQueriesRepository = RecentQueriesRepository(contextProvider: contextProvider)
        
        let viewModel = SearchViewModel(
            searchRepository: searchRepository,
            recentQueriesRepository: recentQueriesRepository
        )
        viewModel.bannerPresenter = homeViewController
        
        let searchViewController = SearchViewController(viewModel: viewModel)
        searchViewController.hideKeyboardResponder = homeViewController
        
        homeViewModel.searchDelegate = viewModel
        
        homeViewController.addChild(searchViewController)
        homeViewController.view.addSubview(searchViewController.view)
        searchViewController.view.frame = homeViewController.view.frame
        searchViewController.didMove(toParent: homeViewController)
        
        self.searchViewController = searchViewController
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
