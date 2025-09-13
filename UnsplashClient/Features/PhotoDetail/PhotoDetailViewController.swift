import UIKit

final class PhotoDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

// MARK: - Model

struct PhotoDetailViewModel {
    let date: String
    
}
