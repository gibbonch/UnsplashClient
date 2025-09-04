import UIKit
import Combine

// MARK: - ThemeManager

final class ThemeManager {
    
    static let shared = ThemeManager()
    
    private var observers = NSHashTable<AnyObject>.weakObjects()
    private var themeObserverView: ThemeObserverView?
    
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
    
    private init() { }
    
    func register(_ observer: Themeable) {
        observers.add(observer)
        observer.applyTheme()
    }
    
    func unregister(_ observer: Themeable) {
        observers.remove(observer)
    }
    
    func setupObserver(in window: UIWindow) {
        guard themeObserverView == nil else { return }
        
        let observerView = ThemeObserverView()
        observerView.isHidden = true
        observerView.isUserInteractionEnabled = false
        
        window.addSubview(observerView)
        observerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            observerView.topAnchor.constraint(equalTo: window.topAnchor),
            observerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            observerView.widthAnchor.constraint(equalToConstant: 1),
            observerView.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        observerView.onThemeChanged = { [weak self] _ in
            self?.notifyObservers()
        }
        
        self.themeObserverView = observerView
    }
    
    private func notifyObservers() {
        DispatchQueue.main.async { [weak self] in
            self?.observers.allObjects.compactMap { $0 as? Themeable }.forEach { observer in
                observer.applyTheme()
            }
        }
    }
}

// MARK: - Themeable

protocol Themeable: AnyObject {
    func applyTheme()
}

// MARK: - ObserverView

final class ThemeObserverView: UIView {
    
    var onThemeChanged: ((UIUserInterfaceStyle) -> Void)? {
        didSet { onThemeChanged?(traitCollection.userInterfaceStyle) }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard
            #available(iOS 13.0, *),
            previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle
        else { return }
        
        onThemeChanged?(traitCollection.userInterfaceStyle)
    }
}
