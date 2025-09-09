import UIKit

enum Colors {
    
    // MARK: - Background Colors
    
    static var backgroundPrimary: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.backgroundPrimary : LightColors.backgroundPrimary
    }
    
    static var backgroundSecondary: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.backgroundSecondary : LightColors.backgroundSecondary
    }
    
    static var backgroundAccent: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.backgroundAccent : LightColors.backgroundAccent
    }
    
    // MARK: - Text Colors
    
    static var textPrimary: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.textPrimary : LightColors.textPrimary
    }
    
    static var textSecondary: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.textSecondary : LightColors.textSecondary
    }
    
    static var textAccent: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.textAccent : LightColors.textAccent
    }
    
    // MARK: - Accent Colors
    
    static var accent: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.accent : LightColors.accent
    }
    
    static var gray: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.gray : LightColors.gray
    }
    
    static var lightGray: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.lightGray : LightColors.lightGray
    }
    
    static var red: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.red : LightColors.red
    }
    
    static var white: UIColor {
        return ThemeManager.shared.isDarkMode ? DarkColors.white : LightColors.white
    }
}

// MARK: - Light Theme Colors

private enum LightColors {
    
    static var backgroundPrimary = UIColor(hex: "#f8f9fa")!
    static var backgroundSecondary = UIColor(hex: "#ffffff")!
    static var backgroundAccent = UIColor(hex: "#000000")!
    
    static var textPrimary = UIColor(hex: "#000000")!
    static var textSecondary = UIColor(hex: "#808186")!
    static var textAccent = UIColor(hex: "#ffffff")!
    
    static var accent = UIColor(hex: "#000000")!
    static var gray = UIColor(hex: "#818185")!
    static var lightGray = UIColor(hex: "#c8c8c8")!
    static var red = UIColor(hex: "#ff4a4a")!
    static var white = UIColor(hex: "#ffffff")!
}

// MARK: - Dark Theme Colors

private enum DarkColors {
    
    static var backgroundPrimary = UIColor(hex: "#0c0c0c")!
    static var backgroundSecondary = UIColor(hex: "#141415")!
    static var backgroundAccent = UIColor(hex: "#ffffff")!
    
    static var textPrimary = UIColor(hex: "#ffffff")!
    static var textSecondary = UIColor(hex: "#8a8a8a")!
    static var textAccent = UIColor(hex: "#000000")!
    
    static var accent = UIColor(hex: "#ffffff")!
    static var gray = UIColor(hex: "#9C9CA3")!
    static var lightGray = UIColor(hex: "#838383")!
    static var red = UIColor(hex: "#ff4a4a")!
    static var white = UIColor(hex: "#ffffff")!
}
