import UIKit
import Combine

final class PhotoFeedViewController: UIViewController, BannerPresenting {
    
    // MARK: - Private Properties
    
    private let viewModel: PhotoFeedViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    private var dataSource: DataSource?
    
    private lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.setTitle("Retry photos upload", for: .normal)
        button.titleLabel?.font = Typography.bodySmall
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        return control
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 22, left: 16, bottom: 22, right: 16)
        collectionView.refreshControl = refreshControl
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: PhotoFeedViewModelProtocol) {
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
        setupDataSource()
        bindViewModel()
        
        viewModel.viewLoaded()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(placeholderView)
        view.addSubview(retryButton)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            retryButton.topAnchor.constraint(equalTo: placeholderView.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 34),
            retryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupDataSource() {
        let registration = UICollectionView.CellRegistration<FeedPhotoCell, FeedPhotoModel> { [weak self] cell, indexPath, model in
            let sizedModel = SizedFeedPhotoModel(
                model: model,
                imageSize: self?.calculateImageSizeForCell(at: indexPath) ?? .zero
            )
            cell.configure(with: sizedModel)
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, model in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: model
            )
        }
    }
    
    private func bindViewModel() {
        viewModel.feedState.sink { [weak self] state in
            self?.updateState(with: state)
        }.store(in: &cancellables)
        
        viewModel.banner.sink { [weak self] banner in
            self?.showBanner(banner)
        }.store(in: &cancellables)
        
        viewModel.isRefreshing.sink { [weak self] isRefreshing in
            if !isRefreshing {
                self?.refreshControl.endRefreshing()
            }
        }.store(in: &cancellables)
    }
    
    private func updateState(with state: PhotoFeedState) {
        switch state {
        case .initial:
            placeholderView.isHidden = true
            retryButton.isHidden = true
            collectionView.isHidden = true
        case .empty(title: let title, subtitle: let subtitle):
            placeholderView.configure(title: title, subtitle: subtitle)
            placeholderView.isHidden = false
            retryButton.isHidden = false
            collectionView.isHidden = true
        case .photos(let models):
            applySnapshot(photos: models)
            placeholderView.isHidden = true
            retryButton.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func applySnapshot(photos: [FeedPhotoModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func calculateImageSizeForCell(at indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width
        let horizontalInsets: CGFloat = 16
        let interItemSpacing: CGFloat = 4
        let imageWidth = width / 2 - horizontalInsets * 2 - interItemSpacing
        
        let resolution = viewModel.photoResolution(at: indexPath)
        let scale = imageWidth / CGFloat(resolution.width)
        
        return CGSize(width: imageWidth, height: CGFloat(resolution.height) * scale)
    }
    
    @objc
    private func retryButtonTapped() {
        viewModel.retryButtonTapped()
    }
    
    @objc
    private func refresh() {
        viewModel.refreshFeed()
    }
}

// MARK: - UICollectionViewDelegate

extension PhotoFeedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.cellSelected(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayCell(at: indexPath)
    }
}

// MARK: - WaterfallLayoutDelegate

extension PhotoFeedViewController: WaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let imageSize = calculateImageSizeForCell(at: indexPath)
        let cellHeight = imageSize.height + FeedPhotoCell.authorViewHeight
        
        return cellHeight
    }
}

// MARK: - Themeable

extension PhotoFeedViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
        retryButton.backgroundColor = Colors.backgroundAccent
        retryButton.setTitleColor(Colors.textAccent, for: .normal)
        refreshControl.tintColor = Colors.gray
    }
}

// MARK: - Section

private enum Section {
    case main
}

// MARK: - Type Aliases

private typealias DataSource = UICollectionViewDiffableDataSource<Section, FeedPhotoModel>
private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FeedPhotoModel>
