import UIKit

enum Colors {
    
    // MARK: - Background
    
    static var backgroundPrimary: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#f8f9fa")!
        default:
            return UIColor(hex: "#0c0c0c")!
        }
    }
    
    static var backgroundSecondary: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#ffffff")!
        default:
            return UIColor(hex: "#141415")!
        }
    }
    
    // MARK: - Text
    
    static var textPrimary: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#000000")!
        default:
            return UIColor(hex: "#ffffff")!
        }
    }
    
    static var textSecondary: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#808186")!
        default:
            return UIColor(hex: "#8a8a8a")!
        }
    }
    
    static var textAccent: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#ffffff")!
        default:
            return UIColor(hex: "#000000")!
        }
    }
    
    // MARK: - Accent & Utility
    
    static var accent: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#000000")!
        default:
            return UIColor(hex: "#ffffff")!
        }
    }
    
    static var gray: UIColor {
        switch ThemeManager.shared.style {
        case .light:
            return UIColor(hex: "#c8c8c8")!
        default:
            return UIColor(hex: "#838383")!
        }
    }
    
    static var red: UIColor {
        UIColor(hex: "#ff4a4a")!
    }
    
    static var white: UIColor {
        UIColor(hex: "#ffffff")!
    }
}
