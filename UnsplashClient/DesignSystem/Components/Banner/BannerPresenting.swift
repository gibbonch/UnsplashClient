import UIKit

protocol BannerPresenting: AnyObject {
    func showBanner(_ banner: Banner)
}

private var bannerQueueAssociationKey: UInt8 = 0

extension BannerPresenting where Self: UIViewController {
    
    private var bannerQueue: BannerQueue {
        if let queue = objc_getAssociatedObject(self, &bannerQueueAssociationKey) as? BannerQueue {
            return queue
        } else {
            let queue = BannerQueue(viewController: self)
            objc_setAssociatedObject(self, &bannerQueueAssociationKey, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return queue
        }
    }
    
    func showBanner(_ banner: Banner) {
        bannerQueue.add(banner: banner)
    }
}
