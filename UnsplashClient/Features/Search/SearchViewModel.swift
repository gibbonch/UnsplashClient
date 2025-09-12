import Foundation
import Combine

protocol SearchNavigationResponder: AnyObject {
    func routeToSearchResults(with query: SearchQuery)
}

protocol SearchViewModelProtocol {
    var recentQueries: AnyPublisher<[RecentQueryCellModel], Never> { get }
    var filterSections: AnyPublisher<[SearchFilterGroup], Never> { get }
    var searchButtonState: AnyPublisher<SearchButtonState, Never> { get }
    
    func didSelectRecentQuery(with id: String)
    func deleteRecentQuery(with id: String)
    func didSelectFilter(_ filter: AnySearchFilter)
    func searchButtonDidTap()
}

final class SearchViewModel: SearchViewModelProtocol {
    
    // MARK: - Internal Properties
    
    weak var responder: SearchNavigationResponder?
    weak var bannerPresenter: BannerPresenter?
    
    var filterSections: AnyPublisher<[SearchFilterGroup], Never> {
        filterGroupsSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var recentQueries: AnyPublisher<[RecentQueryCellModel], Never> {
        recentQueriesSubject
            .map { recentQueries in
                recentQueries.map { recent in
                    RecentQueryCellModel(id: recent.identifier, text: recent.query.text)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var searchButtonState: AnyPublisher<SearchButtonState, Never> {
        searchButtonStateSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private let searchQueryBuilder = SearchQueryBuilder()
    private let searchRepository: SearchRepositoryProtocol
    private let recentQueriesRepository: RecentQueriesRepositoryProtocol
    
    private let filterGroupsSubject = CurrentValueSubject<[SearchFilterGroup], Never>([])
    private let recentQueriesSubject = CurrentValueSubject<[RecentQuery], Never>([])
    private let searchButtonStateSubject = CurrentValueSubject<SearchButtonState, Never>(.hidden)
    
    private let searchPhotosQueue = PassthroughSubject<SearchQuery, Never>()
    private var currentSearchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    private var searchTask: CancellableTask? {
        willSet { searchTask?.cancel() }
    }
    
    private let availableFilters: [FilterType: [AnySearchFilter]] = [
        .orderedBy: OrderedByFilter.allCases.map { $0.eraseToAnySearchFilter() },
        .orientation: OrientationFilter.allCases.map { $0.eraseToAnySearchFilter() },
    ]
    
    // MARK: - Lifecycle
    
    init(searchRepository: SearchRepositoryProtocol, recentQueriesRepository: RecentQueriesRepositoryProtocol) {
        self.searchRepository = searchRepository
        self.recentQueriesRepository = recentQueriesRepository
        
        setupBindings()
        buildSearchFilterGroups(query: searchQueryBuilder.build())
    }
    
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Internal Methods
    
    func didSelectRecentQuery(with id: String) {
        guard let recent = recentQueriesSubject.value.first(where: { $0.identifier == id }) else {
            return
        }
        
        let query = recent.query
        searchQueryBuilder.query(query)
        
        enqueueSearchQuery(query)
        buildSearchFilterGroups(query: query)
        
        responder?.routeToSearchResults(with: query)
        recentQueriesRepository.updateRecentQuery(with: id)
    }
    
    func didSelectFilter(_ filter: AnySearchFilter) {
        searchQueryBuilder.filter(filter)
        let query = searchQueryBuilder.build()
        
        enqueueSearchQuery(query)
        buildSearchFilterGroups(query: query)
    }
    
    func deleteRecentQuery(with id: String) {
        recentQueriesRepository.deleteRecentQuery(with: id)
    }
    
    func searchButtonDidTap() {
        let query = searchQueryBuilder.build()
        guard !query.text.isEmpty else { return }
        responder?.routeToSearchResults(with: query)
        recentQueriesRepository.createRecentQuery(query: query)
    }
    
    // MARK: - Private Methods
    
    private func buildSearchFilterGroups(query: SearchQuery) {
        var groups: [SearchFilterGroup] = []
        
        for type in FilterType.allCases {
            let filters = availableFilters[type] ?? []
            let models = filters.map { filter in
                let isSelected = query.filters.contains { queryFilter in
                    queryFilter.type == filter.type && queryFilter.value == filter.value
                }
                return FilterCellModel(filter: filter, isSelected: isSelected)
            }
            let group = SearchFilterGroup(type: type, filterModels: models)
            groups.append(group)
        }
        
        filterGroupsSubject.send(groups)
    }
    
    private func setupBindings() {
        observeSearchPhotosQueue()
        observeRecentQueries()
    }
    
    private func observeSearchPhotosQueue() {
        searchPhotosQueue
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.searchPhotos(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func enqueueSearchQuery(_ query: SearchQuery) {
        guard !query.text.isEmpty else {
            searchButtonStateSubject.send(.hidden)
            return
        }
        searchPhotosQueue.send(query)
    }
    
    private func searchPhotos(query: SearchQuery) {
        guard !query.text.isEmpty else {
            searchButtonStateSubject.send(.hidden)
            searchTask?.cancel()
            return
        }
        
        guard query.text == currentSearchText else { return }
        
        searchButtonStateSubject.send(.loading)
        searchTask = searchRepository.searchPhotos(query: query, page: 1, perPage: 1) { [weak self] result in
            guard query.text == self?.currentSearchText else { return }
            switch result {
            case .success(let searchResult):
                self?.handleSearchSuccess(searchResult)
            case .failure(let error):
                self?.handleSearchError(error)
            }
        }
    }
    
    private func handleSearchSuccess(_ searchResult: PhotosSearchResult) {
        if searchResult.total == 0 {
            searchButtonStateSubject.send(.empty)
        } else {
            searchButtonStateSubject.send(.search("\(searchResult.total)"))
        }
    }
    
    private func handleSearchError(_ error: Error) {
        if let networkError = error as? NetworkError, case .cancelled = networkError {
            return
        }
        
        let banner = Banner(
            title: "Сouldn't complete the search",
            subtitle: "Try again later",
            type: .error
        )
        DispatchQueue.main.async { [weak self] in
            self?.bannerPresenter?.presentBanner(banner)
        }
        
        searchButtonStateSubject.send(.hidden)
    }
    
    private func observeRecentQueries() {
        recentQueriesRepository
            .observeRecents()
            .sink { [weak self] recentQueries in
                self?.recentQueriesSubject.send(recentQueries)
            }
            .store(in: &cancellables)
    }
}

// MARK: - SearchQueryDelegate

extension SearchViewModel: SearchQueryDelegate {
    
    func didUpdateSearchQuery(_ query: String) {
        currentSearchText = query
        let builtQuery = searchQueryBuilder.text(query).build()
        enqueueSearchQuery(builtQuery)
    }
    
    func didSubmitSearchQuery() {
        searchButtonDidTap()
    }
}

// MARK: - SearchFilterGroup

struct SearchFilterGroup {
    let type: FilterType
    let filterModels: [FilterCellModel]
}
