import UIKit

final class ThemedTabBarController: UITabBarController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.shared.register(self)
        applyTheme()
    }
    
    func applyTheme() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.stackedLayoutAppearance.normal.iconColor = Colors.gray
        appearance.stackedLayoutAppearance.selected.iconColor = Colors.accent
        
        appearance.inlineLayoutAppearance.normal.iconColor = Colors.gray
        appearance.inlineLayoutAppearance.selected.iconColor = Colors.accent
        
        appearance.compactInlineLayoutAppearance.normal.iconColor = Colors.gray
        appearance.compactInlineLayoutAppearance.selected.iconColor = Colors.accent
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: Colors.gray]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: Colors.accent]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
}
