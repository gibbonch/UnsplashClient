final class PhotoFeedAssembly: AssemblyProtocol {
    
    func assemble(diContainer: any DIContainerProtocol) {
        diContainer.register(for: FetchPhotosUseCaseProtocol.self) { diContainer in
            FetchPhotosUseCase(photoRepository: diContainer.resolve(PhotoRepositoryProtocol.self)!)
        }
    }
}
