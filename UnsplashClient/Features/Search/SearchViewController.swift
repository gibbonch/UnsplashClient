import UIKit
import Combine

final class SearchViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    weak var hideKeyboardResponder: HideKeyboardResponder?
    
    // MARK: - Private Properties
    
    private let viewModel: SearchViewModelProtocol
    
    private var cancellabels: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    init(viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.shared.register(self)
        
        setupUI()
        setupConstraints()
        setupGestures()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .red
    }
    
    private func setupConstraints() {
        
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func bindViewModel() {
        viewModel.filterSections.sink { groups in
            for group in groups {
                print(group.type.title)
                for model in group.filterModels {
                    print("\(model.filter.text): \(model.isSelected)", separator: " ")
                }
                print()
            }
        }.store(in: &cancellabels)
        
        viewModel.searchButtonState.sink { state in
            print(state)
        }.store(in: &cancellabels)
    }
    
    @objc
    private func hideKeyboard() {
        hideKeyboardResponder?.hideKeyboard()
    }
}

// MARK: - Themeable

extension SearchViewController: Themeable {
    
    func applyTheme() {
        view.backgroundColor = Colors.backgroundPrimary
    }
}
