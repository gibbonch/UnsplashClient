import UIKit
import Combine

final class SearchViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    weak var hideKeyboardResponder: HideKeyboardResponder?
    
    // MARK: - Private Properties
    
    private let viewModel: SearchViewModelProtocol
    private var cancellabels: Set<AnyCancellable> = []
    
    private var dataSource: DataSource?
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 22, left: 0, bottom: 72, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var searchButton: SearchButton = {
        let button = SearchButton()
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: SearchViewModelProtocol) {
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
        
        setupUI()
        setupConstraints()
        setupGestures()
        setupDataSource()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(searchButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            searchButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupDataSource() {
        let recentCellRegistration = createRecentCellRegistration()
        let filterCellRegistration = createFilterCellRegistration()
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .recent(let model):
                return collectionView.dequeueConfiguredReusableCell(
                    using: recentCellRegistration,
                    for: indexPath,
                    item: model
                )
            case .filter(let model):
                return collectionView.dequeueConfiguredReusableCell(
                    using: filterCellRegistration,
                    for: indexPath,
                    item: model
                )
            }
        }
        
        let headerRegistration = createHeaderRegistration()
        
        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }
    
    private func createRecentCellRegistration() -> UICollectionView.CellRegistration<RecentQueryCell, RecentQueryCellModel> {
        UICollectionView.CellRegistration { cell, _, model in
            cell.configure(with: model)
            cell.onDeleteButtonTapped = { [weak self] id in
                self?.viewModel.deleteRecentQuery(with: id)
            }
        }
    }
    
    private func createFilterCellRegistration() -> UICollectionView.CellRegistration<FilterCell, FilterCellModel> {
        UICollectionView.CellRegistration<FilterCell, FilterCellModel> { cell, _, model in
            cell.configure(with: model)
        }
    }
    
    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<SectionHeaderView> {
        UICollectionView.SupplementaryRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            
            guard let self,
                  elementKind == UICollectionView.elementKindSectionHeader,
                  let section = dataSource?.snapshot().sectionIdentifiers[indexPath.section] else {
                return
            }
            headerView.configure(with: section.title)
        }
    }
    
    private func bindViewModel() {
        Publishers.CombineLatest(viewModel.filterSections, viewModel.recentQueries)
            .sink { [weak self] filterGroups, recentQueries in
                self?.applySnapshot(filterGroups: filterGroups, recentQueries: recentQueries)
            }
            .store(in: &cancellabels)
        
        viewModel.searchButtonState.sink { [weak self] state in
            self?.searchButton.searchState = state
        }.store(in: &cancellabels)
    }

    private func applySnapshot(filterGroups: [FilterGroup], recentQueries: [RecentQueryCellModel]) {
        var snapshot = Snapshot()
        
        if !recentQueries.isEmpty {
            snapshot.appendSections([.recent])
            snapshot.appendItems(
                recentQueries.map { .recent($0) },
                toSection: .recent
            )
        }
        
        for group in filterGroups {
            snapshot.appendSections([.filter(group.type)])
            snapshot.appendItems(
                group.filterModels.map { .filter($0) },
                toSection: .filter(group.type)
            )
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] sectionIndex, layoutEnvironment in
            
            guard let self, let sectionKind = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex] else {
                return nil
            }
            
            switch sectionKind {
            case .recent:
                return createRecentSection()
            default:
                return createListSection(layoutEnvironment: layoutEnvironment)
            }
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func createRecentSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(120),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(120),
            heightDimension: .absolute(30)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 12, leading: 16, bottom: 22, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.edgeSpacing = .init(leading: .fixed(16), top: nil, trailing: .fixed(16), bottom: nil)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    func createListSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .clear
        
        configuration.headerMode = .supplementary
        
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        section.contentInsets = .init(top: 12, leading: 16, bottom: 22, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.edgeSpacing = .init(leading: .fixed(16), top: nil, trailing: .fixed(16), bottom: nil)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    @objc
    private func hideKeyboard() {
        hideKeyboardResponder?.hideKeyboard()
    }
    
    @objc
    private func searchButtonTapped() {
        viewModel.searchButtonDidTap()
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .recent(let model):
            viewModel.didSelectRecentQuery(with: model.id)
        case .filter(let model):
            viewModel.didSelectFilter(model.filter)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
}

// MARK: - Themeable

extension SearchViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}

// MARK: - Item

private enum SearchItem: Hashable {
    case recent(RecentQueryCellModel)
    case filter(FilterCellModel)
}

// MARK: - Section

private enum SearchSection: Hashable {
    case recent
    case filter(FilterType)
    
    var title: String {
        switch self {
        case .recent:
            return "Recent"
        case .filter(let type):
            return type.title
        }
    }
}

private extension FilterType {
    var title: String {
        switch self {
        case .orderedBy:
            return "Ordered by"
        case .orientation:
            return "Orientation"
        case .color:
            return "Color"
        }
    }
}

// MARK: - Type Aliases

private typealias DataSource = UICollectionViewDiffableDataSource<SearchSection, SearchItem>
private typealias Snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>
