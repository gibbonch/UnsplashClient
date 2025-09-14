import UIKit

final class ThemedNavigationController: UINavigationController, BannerPresenting, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.shared.register(self)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        topViewController?.navigationItem.backButtonTitle = ""
        super.pushViewController(viewController, animated: animated)
    }
    
    func applyTheme() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .font: Typography.titleLarge,
            .foregroundColor: Colors.textPrimary,
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        navigationBar.tintColor = Colors.textPrimary
        
        navigationBar.setNeedsLayout()
        navigationBar.layoutIfNeeded()
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
}
