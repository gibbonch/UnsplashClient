import UIKit

final class RecentQueryCell: UICollectionViewCell {
    
    var onDeleteButtonTapped: ((String) -> Void)?
    
    private var recentQueryID: String?
    
    private lazy var queryLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.bodySmall
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.backgroundColor = .clear
        button.setImage(.crossAsset, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    func configure(with model: RecentQueryCellModel) {
        queryLabel.text = model.text
        recentQueryID = model.id
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 15
        contentView.addSubview(queryLabel)
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            queryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            queryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 8),
            deleteButton.widthAnchor.constraint(equalToConstant: 8),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: queryLabel.trailingAnchor, constant: 12),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    @objc
    private func deleteButtonTapped() {
        guard let recentQueryID else { return }
        onDeleteButtonTapped?(recentQueryID)
    }
}

// MARK: - Themeable

extension RecentQueryCell: Themeable {
    func applyTheme() {
        contentView.backgroundColor = Colors.backgroundAccent
        queryLabel.textColor = Colors.textAccent
        deleteButton.tintColor = Colors.textAccent
    }
}

// MARK: - Model

struct RecentQueryCellModel: Hashable {
    let id: String
    let text: String
}
