import UIKit

final class PhotoFeedViewController: UIViewController {
    
    private lazy var feedView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    override func loadView() {
        view = feedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("deinit")
    }
}
