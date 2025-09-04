import UIKit

class ViewController: UIViewController, BannerPresenting {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let button = UIButton(type: .system)
        button.setTitle("show error", for: .normal)
        let action = UIAction { [weak self] _ in
            let banner = Banner(title: "Some", type: .error)
            self?.showBanner(banner)
        }
        button.addAction(action, for: .touchUpInside)
        
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let button2 = UIButton(type: .system)
        button2.setTitle("show banner", for: .normal)
        let action2 = UIAction { [weak self] _ in
            let banner = Banner(title: "The request limit has been reached", subtitle: "Requests are updated at the beginning of each hour", type: .notification)
            self?.showBanner(banner)
        }
        button2.addAction(action2, for: .touchUpInside)
        
        view.addSubview(button2)
        
        button2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button2.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
        ])
        
        ThemeManager.shared.register(self)
    }
}

extension ViewController: ThemeApplyable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}
