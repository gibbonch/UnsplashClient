import UIKit

final class SplashViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: .unsplashAsset)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.shared.register(self)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

extension SplashViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
        imageView.tintColor = Colors.accent
    }
}
