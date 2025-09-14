final class HomeAssembly: AssemblyProtocol {
    
    func assemble(diContainer: any DIContainerProtocol) {
        
        diContainer.register(for: SearchRepositoryProtocol.self) { diContainer in
            SearchRepository(client: diContainer.resolve(NetworkClientProtocol.self)!)
        }
        
        diContainer.register(for: RecentQueriesRepositoryProtocol.self) { diContainer in
            RecentQueriesRepository(contextProvider: diContainer.resolve(ContextProvider.self)!)
        }
        
        diContainer.register(for: FetchPhotosUseCaseProtocol.self) { diContainer in
            FetchPhotosUseCase(
                photoRepository: diContainer.resolve(PhotoRepositoryProtocol.self)!,
                searchRepository: diContainer.resolve(SearchRepositoryProtocol.self)!
            )
        }
        
        diContainer.register(for: PhotoDetailServiceProtocol.self) { diContainer in
            PhotoDetailService(
                photoRepository: diContainer.resolve(PhotoRepositoryProtocol.self)!,
                favoritesRepository: diContainer.resolve(FavoritesRepositoryProtocol.self)!
            )
        }
    }
}
