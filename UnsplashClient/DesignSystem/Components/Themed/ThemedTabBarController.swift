import UIKit

final class ThemedTabBarController: UITabBarController, Themeable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.shared.register(self)
    }
    
    func applyTheme() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.stackedLayoutAppearance.normal.iconColor = Colors.lightGray
        appearance.stackedLayoutAppearance.selected.iconColor = Colors.accent
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: Colors.lightGray]
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
