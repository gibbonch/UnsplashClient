import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    
    private let viewModel: FavoritesViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.configure(
            title: "Nothing here yet",
            subtitle: "Add your favorite photos to your favorites"
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        return control
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 22, left: 0, bottom: 22, right: 0)
        collectionView.refreshControl = refreshControl
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var dataSource: DataSource?
    
    init(viewModel: FavoritesViewModelProtocol) {
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
        navigationItem.title = "Favorites"
        
        setupUI()
        setupConstraints()
        setupDataSource()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    private func setupUI() {
        view.addSubview(placeholderView)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupDataSource() {
        let registration = UICollectionView.CellRegistration<FavoritePhotoCell, URL> { cell, _, url in
            cell.configure(with: url)
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, url in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: url)
        }
    }
    
    private func bindViewModel() {
        viewModel.photos.sink { [weak self] urls in
            self?.applySnapshot(urls: urls)
        }.store(in: &cancellables)
        
        viewModel.isRefreshing.sink { [weak self] isRefreshing in
            if !isRefreshing {
                self?.refreshControl.endRefreshing()
            }
        }.store(in: &cancellables)
    }
    
    private func applySnapshot(urls: [URL]) {
        guard !urls.isEmpty else {
            collectionView.isHidden = true
            placeholderView.isHidden = false
            return
        }
        
        collectionView.isHidden = false
        placeholderView.isHidden = true
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(urls)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 3.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / 3.0)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item, item])
        group.interItemSpacing = .fixed(4)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc
    private func refresh() {
        viewModel.refresh()
    }
}

// MARK: - UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectCell(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayCell(at: indexPath)
    }
}

// MARK: - Themeable

extension FavoritesViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}

// MARK: - Section

private enum Section {
    case main
}

// MARK: - Type Aliases

private typealias DataSource = UICollectionViewDiffableDataSource<Section, URL>
private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, URL>
