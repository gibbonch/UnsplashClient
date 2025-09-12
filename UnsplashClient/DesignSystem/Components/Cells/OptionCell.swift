import UIKit

final class OptionCell: UICollectionViewListCell {
    
    private let optionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.tintColor = Colors.accent
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ThemeManager.shared.register(self)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    private func setupUI() {
        contentView.addSubview(optionLabel)
        contentView.addSubview(checkmarkView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            optionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func configure(title: String, isSelected: Bool, image: UIImage? = nil) {
        optionLabel.text = title
        checkmarkView.isHidden = !isSelected
    }
}

extension OptionCell: Themeable {
    func applyTheme() {
        backgroundColor = Colors.backgroundSecondary
    }
}
