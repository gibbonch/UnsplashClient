import UIKit

final class ColorImageService {
    
    private var cache: [[String]: UIImage] = [:]
    private let borderWidth: CGFloat = 0.5
    private let imageSize = CGSize(width: 30, height: 30)
    private let borderColor = Colors.gray
    
    func createImageForColor(hex: [String]) -> UIImage? {
        if let cachedImage = cache[hex] {
            return cachedImage
        }
        
        let image: UIImage?
        
        switch hex.count {
        case 1:
            image = createSingleColorCircle(hex: hex[0])
        case 2:
            image = createDualColorCircle(leftHex: hex[0], rightHex: hex[1])
        default:
            return nil
        }
        
        if let image = image {
            cache[hex] = image
        }
        
        return image
    }
    
    private func createSingleColorCircle(hex: String) -> UIImage? {
        guard let fillColor = UIColor(hex: hex) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            let inset = borderWidth / 2
            let circleRect = CGRect(
                x: inset,
                y: inset,
                width: imageSize.width - borderWidth,
                height: imageSize.height - borderWidth
            )
            
            cgContext.setFillColor(fillColor.cgColor)
            cgContext.fillEllipse(in: circleRect)
            
            if borderWidth > 0 {
                cgContext.setStrokeColor(borderColor.cgColor)
                cgContext.setLineWidth(borderWidth)
                cgContext.strokeEllipse(in: circleRect)
            }
        }
    }
    
    private func createDualColorCircle(leftHex: String, rightHex: String) -> UIImage? {
        guard let leftColor = UIColor(hex: leftHex),
              let rightColor = UIColor(hex: rightHex) else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            let inset = borderWidth / 2
            let circleRect = CGRect(
                x: inset,
                y: inset,
                width: imageSize.width - borderWidth,
                height: imageSize.height - borderWidth
            )
            
            cgContext.addEllipse(in: circleRect)
            cgContext.clip()
            
            let leftRect = CGRect(
                x: circleRect.minX,
                y: circleRect.minY,
                width: circleRect.width / 2,
                height: circleRect.height
            )
            cgContext.setFillColor(leftColor.cgColor)
            cgContext.fill(leftRect)
            
            let rightRect = CGRect(
                x: circleRect.midX,
                y: circleRect.minY,
                width: circleRect.width / 2,
                height: circleRect.height
            )
            cgContext.setFillColor(rightColor.cgColor)
            cgContext.fill(rightRect)
            
            cgContext.resetClip()
            
            if borderWidth > 0 {
                cgContext.setStrokeColor(borderColor.cgColor)
                cgContext.setLineWidth(borderWidth)
                cgContext.strokeEllipse(in: circleRect)
            }
            
            drawCenterDivider(in: cgContext, circleRect: circleRect)
        }
    }
    
    private func drawCenterDivider(in context: CGContext, circleRect: CGRect) {
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(0.5)
        
        let centerX = circleRect.midX
        let startY = circleRect.minY + circleRect.height * 0.15
        let endY = circleRect.maxY - circleRect.height * 0.15
        
        context.move(to: CGPoint(x: centerX, y: startY))
        context.addLine(to: CGPoint(x: centerX, y: endY))
        context.strokePath()
    }
}
