import UIKit

extension UIColor {
    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        guard hex.hasPrefix("#") else { return nil }
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        guard hexColor.count == 6 else { return nil }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            blue = CGFloat(hexNumber & 0x0000FF) / 255
            
            self.init(red: red, green: green, blue: blue, alpha: alpha)
            return
        }
        
        return nil
    }
}
