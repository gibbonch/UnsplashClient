import UIKit

final class HomeViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        ThemeManager.shared.register(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Unsplash"
    }
}

extension HomeViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}
