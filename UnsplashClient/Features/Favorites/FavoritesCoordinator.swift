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
        let provider = diContainer.resolve(ContextProvider.self)!
        let repository = FavoritesRepository(contextProvider: provider)
        let viewModel = FavoritesViewModel(favoritesRepository: repository)
        viewModel.responder = self
        let favoritesViewController = FavoritesViewController(viewModel: viewModel)
        navigationController.setViewControllers([favoritesViewController], animated: false)
    }
    
    func showPhotoDetail(id: String) {
        let photoRepository = diContainer.resolve(PhotoRepositoryProtocol.self)!
        let contextProvider = diContainer.resolve(ContextProvider.self)!
        let favoritesRepository = FavoritesRepository(contextProvider: contextProvider)
        let service = PhotoDetailService(photoRepository: photoRepository, favoritesRepository: favoritesRepository)
        let viewModel = PhotoDetailViewModel(id: id, service: service)
        viewModel.responder = self
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension FavoritesCoordinator: FavoritesNavigationResponder {
    func routeToDetail(id: String) {
        showPhotoDetail(id: id)
    }
}

extension FavoritesCoordinator: PhotoDetailNavigationResponder {
    
    func dismissScene() {
        navigationController.popViewController(animated: true)
        
        if let presenter = navigationController as? BannerPresenting {
            let banner = Banner(title: "Something went wrong", type: .error)
            presenter.showBanner(banner)
        }
    }
}
