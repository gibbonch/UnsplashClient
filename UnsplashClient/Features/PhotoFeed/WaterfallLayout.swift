import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat
}

final class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelegate?
    
    private let numberOfColumns = 2
    
    private let cellPadding: CGFloat = 4
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty,
              let collectionView = collectionView,
              collectionView.numberOfSections > 0 else {
            return
        }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        guard numberOfItems > 0 else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForCellAtIndexPath: indexPath) ?? 180
            
            let height = cellPadding * 2 + photoHeight
            
            let frame = CGRect(
                x: xOffset[column],
                y: yOffset[column],
                width: columnWidth,
                height: height
            )
            
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            yOffset[column] += height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in cache where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache.count else {
            return nil
        }
        return cache[indexPath.item]
    }
}
