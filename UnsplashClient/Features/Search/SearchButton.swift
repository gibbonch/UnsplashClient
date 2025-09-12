import UIKit

final class SearchButton: UIButton {
    
    var searchState: SearchButtonState = .hidden {
        didSet {
            updateUI()
        }
    }
    
    private lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ThemeManager.shared.register(self)
        setupUI()
        setupConstraints()
        updateUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    private func setupUI() {
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func updateUI() {
        switch searchState {
        case .hidden:
            isHidden = true
            activityView.stopAnimating()
            
        case .loading:
            isHidden = false
            isEnabled = false
            setTitle("", for: .normal)
            activityView.startAnimating()
            
        case .search(let query):
            isHidden = false
            isEnabled = true
            activityView.stopAnimating()
            setTitle("Found \(query) photos", for: .normal)
            titleLabel?.font = Typography.bodyMedium
            
        case .empty:
            isHidden = false
            isEnabled = false
            activityView.stopAnimating()
            setTitle("Nothing was found", for: .normal)
            titleLabel?.font = Typography.bodyMedium
        }
        
        applyTheme()
    }
}

extension SearchButton: Themeable {
    func applyTheme() {
        switch searchState {
        case .hidden:
            break
        case .loading:
            backgroundColor = Colors.backgroundAccent
            activityView.color = Colors.textAccent
        case .search:
            backgroundColor = Colors.backgroundAccent
            setTitleColor(Colors.textAccent, for: .normal)
        case .empty:
            backgroundColor = Colors.backgroundAccent
            setTitleColor(Colors.textSecondary, for: .normal)
        }
    }
}

// MARK: - State

enum SearchButtonState {
    case hidden
    case loading
    case search(String)
    case empty
}
