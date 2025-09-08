protocol HomeViewModelProtocol {
    
    func searchTextDidChange(_ text: String)
    func searchButtonDidTap()
    func searchDidCancel()
    func searchDidBeginEditing()
}

protocol HomeNavigationResponder: AnyObject {
    func startSearchFlow()
    func stopSearchFlow()
}

protocol SearchQueryDelegate: AnyObject {
    func didUpdateSearchQuery(_ query: String)
    func didSubmitSearchQuery()
}

final class HomeViewModel: HomeViewModelProtocol {
    
    weak var responder: HomeNavigationResponder?
    weak var searchDelegate: SearchQueryDelegate?
    
    func searchTextDidChange(_ text: String) {
        searchDelegate?.didUpdateSearchQuery(text)
    }
    
    func searchButtonDidTap() {
        searchDelegate?.didSubmitSearchQuery()
    }
    
    func searchDidCancel() {
        responder?.stopSearchFlow()
    }
    
    func searchDidBeginEditing() {
        responder?.startSearchFlow()
    }
}
