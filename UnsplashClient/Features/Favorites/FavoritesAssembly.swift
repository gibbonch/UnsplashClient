final class FavoritesAssembly: AssemblyProtocol {
    
    func assemble(diContainer: any DIContainerProtocol) {
        
        diContainer.register(for: PhotoDetailServiceProtocol.self) { diContainer in
            PhotoDetailService(
                photoRepository: diContainer.resolve(PhotoRepositoryProtocol.self)!,
                favoritesRepository: diContainer.resolve(FavoritesRepositoryProtocol.self)!
            )
        }
    }
}
