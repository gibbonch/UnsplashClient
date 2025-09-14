import UIKit
import Kingfisher

class ZoomableImageView: UIScrollView {
    
    // MARK: - Properties
    private let imageView = UIImageView()
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupImageView()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupImageView()
        setupGestures()
    }
    
    // MARK: - Setup Methods
    private func setupScrollView() {
        delegate = self
        minimumZoomScale = 1.0
        maximumZoomScale = 3.0
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        backgroundColor = .black
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
    }
    
    private func setupGestures() {
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func setupImage() {
        guard let image = imageView.image else {
            imageView.image = nil
            return
        }
        
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)
        contentSize = image.size
        
        // Настраиваем зум после установки изображения
        setNeedsLayout()
        layoutIfNeeded()
        setupInitialZoom()
    }
    
    private func setupInitialZoom() {
        guard let image = imageView.image else { return }
        
        let scrollViewFrame = bounds
        let imageSize = image.size
        
        // Вычисляем минимальный масштаб для помещения изображения в bounds
        let widthScale = scrollViewFrame.width / imageSize.width
        let heightScale = scrollViewFrame.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        minimumZoomScale = minScale
        maximumZoomScale = max(minScale * 3.0, 3.0)
        zoomScale = minScale
        
        centerContent()
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView.image != nil {
            setupInitialZoom()
        }
    }
    
    // MARK: - Centering
    private func centerContent() {
        let scrollViewSize = bounds.size
        let imageViewSize = imageView.frame.size
        
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    // MARK: - Gestures
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let targetZoom: CGFloat
        
        if zoomScale > minimumZoomScale {
            // Если уже увеличено - вернуться к минимальному масштабу
            targetZoom = minimumZoomScale
        } else {
            // Если на минимальном масштабе - увеличить в 2 раза или до максимума
            targetZoom = min(maximumZoomScale, minimumZoomScale * 2.0)
        }
        
        // Получаем точку тапа относительно imageView
        let pointInImageView = recognizer.location(in: imageView)
        
        // Вычисляем прямоугольник для зума
        let zoomWidth = frame.width / targetZoom
        let zoomHeight = frame.height / targetZoom
        let zoomX = pointInImageView.x - zoomWidth / 2
        let zoomY = pointInImageView.y - zoomHeight / 2
        
        let zoomRect = CGRect(x: zoomX, y: zoomY, width: zoomWidth, height: zoomHeight)
        
        // Анимированный зум
        zoom(to: zoomRect, animated: true)
    }
    
    // MARK: - Public Methods
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
        setupImage()
    }
    
    func setImage(from url: URL) {
        imageView.kf.setImage(with: url) { [weak self] _ in
            self?.setupImage()
        }
    }
    
    func resetZoom(animated: Bool = true) {
        setZoomScale(minimumZoomScale, animated: animated)
    }
}

// MARK: - UIScrollViewDelegate
extension ZoomableImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }
}
