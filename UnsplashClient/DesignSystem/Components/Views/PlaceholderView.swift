import UIKit

final class PlaceholderView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: .unsplashAsset)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.bodySmall
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.caption
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ThemeManager.shared.register(self)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    func configure(title: String, subtitle: String? = nil, image: UIImage? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let image {
            imageView.image = image
        }
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(labelStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            labelStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension PlaceholderView: Themeable {
    
    func applyTheme() {
        backgroundColor = .clear
        imageView.tintColor = Colors.gray
        titleLabel.textColor = Colors.gray
        subtitleLabel.textColor = Colors.gray
    }
}
