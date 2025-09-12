import UIKit

protocol HideKeyboardResponder: AnyObject {
    func hideKeyboard()
}

final class HomeViewController: UIViewController, BannerPresenting {
    
    private let viewModel: HomeViewModelProtocol
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search photos"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.shared.register(self)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Unsplash"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.searchDidBeginEditing()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchDidCancel()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTextDidChange(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchButtonDidTap()
    }
}

// MARK: - Themeable

extension HomeViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}

// MARK: - HideKeyboardResponder

extension HomeViewController: HideKeyboardResponder {
    
    func hideKeyboard() {
        searchController.searchBar.endEditing(true)
    }
}

// MARK: - BannerPresenter

extension HomeViewController: BannerPresenter {
    
    func presentBanner(_ banner: Banner) {
        showBanner(banner)
    }
}

// MARK: - SearchBarOwner

extension HomeViewController: SearchBarOwner {
    
    func setText(_ text: String) {
        searchController.searchBar.text = text
        hideKeyboard()
    }
}
