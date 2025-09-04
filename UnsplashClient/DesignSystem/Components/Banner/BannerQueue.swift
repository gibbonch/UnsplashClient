import UIKit

class BannerQueue {
    private weak var viewController: UIViewController?
    private var queue: [Banner] = []
    private var isShowingBanner = false
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func add(banner: Banner) {
        queue.append(banner)
        processQueue()
    }
    
    private func processQueue() {
        guard let viewController, !isShowingBanner, !queue.isEmpty else { return }
        
        let banner = queue.removeFirst()
        isShowingBanner = true
        
        let bannerView = BannerView()
        bannerView.present(in: viewController, with: banner) { [weak self] in
            self?.isShowingBanner = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.processQueue()
            }
        }
    }
}
