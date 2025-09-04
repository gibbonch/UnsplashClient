import UIKit
import Combine

// MARK: - ThemeManager

final class ThemeManager {
    
    static let shared = ThemeManager()
    
    private(set) var style: UIUserInterfaceStyle = .unspecified {
        didSet {
            guard style != oldValue else { return }
            notifyComponents()
        }
    }
    
    private var components = NSHashTable<AnyObject>.weakObjects()
    
    private lazy var observerView: ThemeObserverView = {
        let view = ThemeObserverView()
        view.isHidden = true
        view.onThemeChanged = { [weak self] style in
            self?.style = style
        }
        return view
    }()
    
    private init() { }
    
    func setup(with window: UIWindow) {
        style = window.traitCollection.userInterfaceStyle
        window.addSubview(observerView)
    }
    
    func register(_ component: ThemeApplyable) {
        components.add(component)
        component.applyTheme()
    }
    
    func unregister(_ component: ThemeApplyable) {
        components.remove(component)
    }
    
    private func notifyComponents() {
        for case let component as ThemeApplyable in components.allObjects {
            component.applyTheme()
        }
    }
}

// MARK: - ThemeApplyable

protocol ThemeApplyable: AnyObject {
    func applyTheme()
}

// MARK: - ObserverView

final class ThemeObserverView: UIView {
    
    var onThemeChanged: ((UIUserInterfaceStyle) -> Void)?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard
            #available(iOS 13.0, *),
            previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle
        else { return }
        
        onThemeChanged?(traitCollection.userInterfaceStyle)
    }
}
