import UIKit
import Combine

final class PhotoFeedViewController: UIViewController, BannerPresenting {
    
    // MARK: - Private Properties
    
    private let viewModel: PhotoFeedViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    private var dataSource: DataSource?
    
    private lazy var collectionView: UICollectionView = {
        let layout = WaterfallLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 22, left: 16, bottom: 22, right: 16)
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
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
        viewModel.feedPhotos.sink { [weak self] photos in
            self?.applySnapshot(photos: photos)
        }.store(in: &cancellables)
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
}

// MARK: - UICollectionViewDelegate

extension PhotoFeedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
    }
}

// MARK: - Section

private enum Section {
    case main
}

// MARK: - Type Aliases

private typealias DataSource = UICollectionViewDiffableDataSource<Section, FeedPhotoModel>
private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FeedPhotoModel>
