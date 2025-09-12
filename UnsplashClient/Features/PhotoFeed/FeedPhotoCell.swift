import UIKit
import Kingfisher

final class FeedPhotoCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    
    static let authorViewHeight: CGFloat = 26
    
    // MARK: - Private Properties
    
    private lazy var authorView: AuthorView = {
        let view = AuthorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var shouldApplyTheme = true
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        ThemeManager.shared.unregister(self)
        shouldApplyTheme = true
        
        authorView.avatarImageView.kf.cancelDownloadTask()
        photoImageView.kf.cancelDownloadTask()
        
        super.prepareForReuse()
    }
    
    // MARK: - Internal Methods
    
    func configure(with sizedModel: SizedFeedPhotoCellModel) {
        ThemeManager.shared.register(self)
        
        let model = sizedModel.model
        let size = sizedModel.imageSize
        
        authorView.authorLabel.text = model.username
        
        authorView.avatarImageView.kf.setImage(with: model.avatar)
        
        let downsamplingImageProcessor = DownsamplingImageProcessor(size: size)
        photoImageView.kf.setImage(with: model.photo, options: [.processor(downsamplingImageProcessor)])
        
        if let photoColor = UIColor(hex: model.hex) {
            authorView.avatarImageView.backgroundColor = photoColor
            photoImageView.backgroundColor = photoColor
            shouldApplyTheme = false
        } else {
            applyTheme()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(authorView)
        contentView.addSubview(photoImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            authorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: authorView.bottomAnchor, constant: 4),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

// MARK: - Themeable

extension FeedPhotoCell: Themeable {
    
    func applyTheme() {
        if shouldApplyTheme {
            authorView.avatarImageView.backgroundColor = Colors.lightGray
            photoImageView.backgroundColor = Colors.lightGray
        }
    }
}
