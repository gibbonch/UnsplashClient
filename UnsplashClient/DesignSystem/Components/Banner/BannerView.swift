import UIKit

final class BannerView: UIView {
    
    // MARK: - Subviews
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.bodySmall
        label.textAlignment = .left
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.captionSmall
        label.textAlignment = .left
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Layout.textSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Private Properties
    
    private var banner: Banner?
    private var topConstraint: NSLayoutConstraint?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var hideTimer: Timer?
    private var completion: (() -> Void)?
    
    // MARK: - Constants
    
    private enum Layout {
        static let cornerRadius: CGFloat = 12
        static let topMargin: CGFloat = 70
        static let iconSize: CGFloat = 28
        static let bannerHeight: CGFloat = 55
        static let horizontalInset: CGFloat = 8
        static let textSpacing: CGFloat = 5
    }
    
    private enum Animation {
        static let showDuration: TimeInterval = 0.5
        static let hideDuration: TimeInterval = 0.5
        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5
        static let autoHideDelay: TimeInterval = 3.0
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ThemeManager.shared.register(self)
        setupUI()
        setupConstraints()
        setupGestureRecognizer()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    // MARK: - Internal Methods
    
    func present(in viewController: UIViewController, with banner: Banner, completion: @escaping () -> Void) {
        self.banner = banner
        self.completion = completion
        configureContent(with: banner)
        applyTheme()
        
        viewController.view.addSubview(self)
        
        topConstraint = topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: -Layout.bannerHeight)
        
        guard let topConstraint else { return }
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: Layout.horizontalInset),
            trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -Layout.horizontalInset),
            topConstraint,
        ])
        
        viewController.view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: Animation.showDuration,
            delay: 0,
            usingSpringWithDamping: Animation.springDamping,
            initialSpringVelocity: Animation.springVelocity,
            options: [.curveEaseOut]
        ) {
            self.topConstraint?.constant = Layout.topMargin
            viewController.view.layoutIfNeeded()
        }
        
        startAutoHideTimer()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Layout.cornerRadius
        addSubview(iconImageView)
        addSubview(textStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.bannerHeight),
            
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
            
            textStackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 8),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8),
        ])
    }
    
    private func setupGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func configureContent(with banner: Banner) {
        titleLabel.text = banner.title
        subtitleLabel.text = banner.subtitle
        
        switch banner.type {
        case .notification:
            iconImageView.image = .unsplashAsset
        case .error:
            iconImageView.image = .errorAsset
        }
        
        textStackView.addArrangedSubview(titleLabel)
        if let _ = banner.subtitle {
            textStackView.addArrangedSubview(subtitleLabel)
        }
    }
    
    private func hide() {
        stopAutoHideTimer()
        
        UIView.animate(
            withDuration: Animation.hideDuration,
            delay: 0,
            usingSpringWithDamping: Animation.springDamping,
            initialSpringVelocity: Animation.springVelocity
        ) {
            self.topConstraint?.constant = -self.bounds.height - 20
            self.alpha = 0
            self.transform = .identity
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
            self.completion?()
        }
    }
    
    private func startAutoHideTimer() {
        stopAutoHideTimer()
        hideTimer = Timer.scheduledTimer(withTimeInterval: Animation.autoHideDelay, repeats: false) { [weak self] _ in
            self?.hide()
        }
    }
    
    private func stopAutoHideTimer() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            stopAutoHideTimer()
            
        case .changed:
            if translation.y < 0 {
                topConstraint?.constant = Layout.topMargin + translation.y
            } else {
                let resistance: CGFloat = 0.95
                let downwardMovement = sqrt(translation.y) * resistance
                topConstraint?.constant = Layout.topMargin + downwardMovement
            }
            
        case .ended, .cancelled:
            if velocity.y < -500 || translation.y < -50 {
                hide()
            } else {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: Animation.springDamping,
                    initialSpringVelocity: Animation.springVelocity
                ) {
                    self.topConstraint?.constant = Layout.topMargin
                    self.transform = .identity
                    self.superview?.layoutIfNeeded()
                } completion: { _ in
                    self.startAutoHideTimer()
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - Themeable

extension BannerView: Themeable {
    func applyTheme() {
        guard let banner else { return }
        switch banner.type {
        case .notification:
            backgroundColor = Colors.accent
            [titleLabel, subtitleLabel].forEach { $0.textColor = Colors.textAccent }
            iconImageView.tintColor = Colors.textAccent
        case .error:
            backgroundColor = Colors.red
            [titleLabel, subtitleLabel].forEach { $0.textColor = Colors.white }
            iconImageView.tintColor = Colors.white
        }
    }
}
