import UIKit

final class PhotoDateView: UIView {
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.caption
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ThemeManager.shared.register(self)
        applyTheme()
        
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
    
    func setText(_ text: String?) {
        dateLabel.text = text
        layoutIfNeeded()
    }
    
    private func setupUI() {
        addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            dateLabel.topAnchor.constraint(equalTo: topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension PhotoDateView: Themeable {
    func applyTheme() {
        backgroundColor = Colors.backgroundAccent
        dateLabel.textColor = Colors.textAccent
    }
}
