import Foundation
import CoreData
import Combine

protocol RecentQueriesRepositoryProtocol {
    func createRecentQuery(query: SearchQuery)
    func updateRecentQuery(with id: String)
    func deleteRecentQuery(with id: String)
    func observeRecents() -> AnyPublisher<[RecentQuery], Never>
}

final class RecentQueriesRepository: NSObject, RecentQueriesRepositoryProtocol {
    
    private let contextProvider: ContextProvider
    private var fetchedResultsController: NSFetchedResultsController<RecentQueryDTO>?
    private let recentsSubject: CurrentValueSubject<[RecentQuery], Never> = .init([])
    
    init(contextProvider: ContextProvider) {
        self.contextProvider = contextProvider
        super.init()
        setupSearchResultsController()
        performInitialFetch()
    }
    
    func createRecentQuery(query: SearchQuery) {
        let context = contextProvider.viewContext
        let dto = RecentQueryDTO(query: query, context: context)
        dto.timestamp = Date()
        saveContext(context)
    }
    
    func updateRecentQuery(with id: String) {
        let context = contextProvider.viewContext
        let dto = fetchRecent(with: id, context: context)
        dto?.timestamp = Date()
        saveContext(context)
    }
    
    func deleteRecentQuery(with id: String) {
        let context = contextProvider.viewContext
        guard let dto = fetchRecent(with: id, context: context) else { return }
        context.delete(dto)
        saveContext(context)
    }
    
    func observeRecents() -> AnyPublisher<[RecentQuery], Never> {
        return recentsSubject.eraseToAnyPublisher()
    }
    
    private func fetchRecent(with id: String, context: NSManagedObjectContext) -> RecentQueryDTO? {
        let request = RecentQueryDTO.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(RecentQueryDTO.identifier), id)
        
        let dto = try? context.fetch(request).first
        return dto
    }
    
    private func setupSearchResultsController() {
        let context = contextProvider.viewContext
        let request = RecentQueryDTO.fetchRequest()
        let descriptor = NSSortDescriptor(key: #keyPath(RecentQueryDTO.timestamp), ascending: false)
        request.sortDescriptors = [descriptor]
        request.fetchLimit = 50
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
    }
    
    private func performInitialFetch() {
        do {
            try fetchedResultsController?.performFetch()
            updateRecentsSubject()
        } catch {
            recentsSubject.send([])
        }
    }
    
    private func updateRecentsSubject() {
        guard let dtos = fetchedResultsController?.fetchedObjects else {
            recentsSubject.send([])
            return
        }
        
        let recents = dtos.compactMap { dto -> RecentQuery? in
            guard let identifier = dto.identifier,
                  let timestamp = dto.timestamp,
                  let query = dto.mapToDomain()
            else { return nil }
            
            return RecentQuery(identifier: identifier, timestamp: timestamp, query: query)
        }
        recentsSubject.send(recents)
    }
    
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension RecentQueriesRepository: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        updateRecentsSubject()
    }
}
