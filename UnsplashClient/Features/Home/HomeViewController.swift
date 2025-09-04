import UIKit

protocol HomeNavigationResponder: AnyObject {
    func homeViewControllerDidStartSearch(_ vc: HomeViewController)
    func homeViewControllerDidEndSearch(_ vc: HomeViewController)
}

final class HomeViewController: UIViewController {
    
    //    private let viewModel: HomeViewModel
    weak var delegate: HomeNavigationResponder?
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search photos"
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    init() {
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
    }
}

// MARK: - UISearchBarDelegate

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.homeViewControllerDidStartSearch(self)
        print("startEditing")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            print("cleared")
        } else {
            print(searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.homeViewControllerDidEndSearch(self)
        print("canceled")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
    }
}

// MARK: - Themeable

extension HomeViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}
