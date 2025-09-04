import UIKit

final class ThemedNavigationController: UINavigationController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.shared.register(self)
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
        
        navigationBar.setNeedsLayout()
        navigationBar.layoutIfNeeded()
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
}
