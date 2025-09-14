import UIKit
import Combine
import Kingfisher

final class PhotoDetailViewController: UIViewController {
    
    // MARK: - Private Properites
    
    private let viewModel: PhotoDetailViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var imageScrollView: ImageScrollView = {
        let view = ImageScrollView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dateView: PhotoDateView = {
        let view = PhotoDateView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(favoriteButtonDidTap), for: .touchUpInside)
        let image = UIImage.heartAsset
            .resized(size: .init(width: 18, height: 18))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dateView, favoriteButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.isHidden = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var isLiked = false
    
    // MARK: - Lifecycle
    
    init(viewModel: PhotoDetailViewModelProtocol) {
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
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.addSubview(imageScrollView)
        view.addSubview(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            dateView.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    private func bindViewModel() {
        viewModel.photoDetail.sink { [weak self] model in
            guard let model else { return }
            self?.updateUI(with: model)
        }.store(in: &cancellables)
        
        viewModel.isLiked.sink { [weak self] isLiked in
            self?.updateFavoriteButton(isLiked: isLiked)
        }.store(in: &cancellables)
    }
    
    private func updateUI(with model: PhotoDetailViewUIModel) {
        switch model.photo {
        case .remote(let url):
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                switch result {
                case .success(let retrieveResult):
                    let image = retrieveResult.image
                    DispatchQueue.main.async {
                        self?.imageScrollView.setImage(image)
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self?.viewModel.imageLoadingFailed()
                    }
                }
            }
        case .local(let url):
            if let image = UIImage(contentsOfFile: url.path) {
                imageScrollView.setImage(image)
            } else {
                viewModel.imageLoadingFailed()
            }
        }
        dateView.setText(model.date)
        stackView.isHidden = false
    }
    
    private func updateFavoriteButton(isLiked: Bool) {
        self.isLiked = isLiked
        favoriteButton.tintColor = isLiked ? Colors.red : Colors.textAccent
    }
    
    @objc
    private func favoriteButtonDidTap() {
        viewModel.favoriteButtonTapped()
    }
}

// MARK: - Themeable

extension PhotoDetailViewController: Themeable {
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
        favoriteButton.backgroundColor = Colors.backgroundAccent
        favoriteButton.tintColor = isLiked ? Colors.red : Colors.textAccent
    }
}

// MARK: - Model

struct PhotoDetailViewUIModel {
    let photo: PhotoSource
    let color: Hex
    let date: String
    let resolution: Photo.Resolution
}
