import UIKit
import Kingfisher

final class AuthorView: UIView {
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 11
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.caption
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(authorLabel)
        addSubview(avatarImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 22),
            avatarImageView.widthAnchor.constraint(equalToConstant: 22),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 5),
            authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            authorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
