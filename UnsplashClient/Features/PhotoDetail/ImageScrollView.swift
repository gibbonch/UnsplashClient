import UIKit

final class ImageScrollView: UIScrollView {
    
    private var imageZoomView: UIImageView?
    
    private lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage) {
        removeCurrentImage()
        createImageView(with: image)
        configureForImage(size: image.size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerImage()
    }
    
    // MARK: - Private Methods
    
    private func setupScrollView() {
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        contentInsetAdjustmentBehavior = .automatic
    }
    
    private func removeCurrentImage() {
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
    }
    
    private func createImageView(with image: UIImage) {
        imageZoomView = UIImageView(image: image)
        imageZoomView?.layer.cornerRadius = 16
        guard let imageZoomView = imageZoomView else { return }
        addSubview(imageZoomView)
    }
    
    private func configureForImage(size: CGSize) {
        guard let imageZoomView = imageZoomView else { return }
        
        imageZoomView.frame = CGRect(origin: .zero, size: size)
        contentSize = size
        
        setZoomScales()
        zoomScale = minimumZoomScale
        
        setupImageInteraction()
        updateLayout()
    }
    
    private func setupImageInteraction() {
        guard let imageZoomView = imageZoomView else { return }
        imageZoomView.addGestureRecognizer(zoomingTap)
        imageZoomView.isUserInteractionEnabled = true
    }
    
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setZoomScales() {
        guard let imageZoomView = imageZoomView else { return }
        
        let availableSize = getAvailableSize()
        let imageSize = imageZoomView.bounds.size
        
        guard isValidSize(imageSize) && isValidSize(availableSize) else { return }
        
        let xScale = availableSize.width / imageSize.width
        let yScale = availableSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        minimumZoomScale = minScale
        maximumZoomScale = calculateMaxZoomScale(for: minScale)
    }
    
    private func getAvailableSize() -> CGSize {
        return CGSize(
            width: bounds.width - adjustedContentInset.left - adjustedContentInset.right,
            height: bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
        )
    }
    
    private func isValidSize(_ size: CGSize) -> Bool {
        return size.width > 0 && size.height > 0
    }
    
    private func calculateMaxZoomScale(for minScale: CGFloat) -> CGFloat {
        if minScale < 0.1 {
            return 0.3
        } else if minScale >= 0.1 && minScale < 0.5 {
            return 0.7
        } else {
            return max(1.0, minScale)
        }
    }
    
    private func centerImage() {
        guard let imageZoomView = imageZoomView else { return }
        
        let availableSize = getAvailableSize()
        var frameToCenter = imageZoomView.frame
        
        frameToCenter.origin.x = calculateHorizontalCenter(for: frameToCenter, availableSize: availableSize)
        frameToCenter.origin.y = calculateVerticalCenter(for: frameToCenter, availableSize: availableSize)
        
        imageZoomView.frame = frameToCenter
    }
    
    private func calculateHorizontalCenter(for frame: CGRect, availableSize: CGSize) -> CGFloat {
        if frame.size.width < availableSize.width {
            return adjustedContentInset.left + (availableSize.width - frame.size.width) / 2
        } else {
            return 0
        }
    }
    
    private func calculateVerticalCenter(for frame: CGRect, availableSize: CGSize) -> CGFloat {
        if frame.size.height < availableSize.height {
            return (availableSize.height - frame.size.height) / 2
        } else {
            return 0
        }
    }
    
    private func createZoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        let bounds = self.bounds
        let size = CGSize(
            width: bounds.size.width / scale,
            height: bounds.size.height / scale
        )
        let origin = CGPoint(
            x: center.x - (size.width / 2),
            y: center.y - (size.height / 2)
        )
        
        return CGRect(origin: origin, size: size)
    }
    
    @objc
    private func handleZoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        zoomToPoint(location, animated: true)
    }
    
    private func zoomToPoint(_ point: CGPoint, animated: Bool) {
        let currentScale = zoomScale
        let minScale = minimumZoomScale
        let maxScale = maximumZoomScale
        
        guard minScale != maxScale || minScale <= 1 else { return }
        
        let targetScale = currentScale == minScale ? maxScale : minScale
        let zoomRect = createZoomRect(scale: targetScale, center: point)
        zoom(to: zoomRect, animated: animated)
    }
}

// MARK: - UIScrollViewDelegate

extension ImageScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
}
