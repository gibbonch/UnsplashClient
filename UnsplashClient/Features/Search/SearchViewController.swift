import UIKit

final class SearchViewController: UIViewController {
    
    weak var hideKeyboardResponder: HideKeyboardResponder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func hideKeyboard() {
        hideKeyboardResponder?.hideKeyboard()
    }
}
