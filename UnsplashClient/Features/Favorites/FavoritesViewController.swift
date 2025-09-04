import UIKit

final class FavoritesViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        ThemeManager.shared.register(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "favorites"
    }
}

extension FavoritesViewController: ThemeApplyable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}
