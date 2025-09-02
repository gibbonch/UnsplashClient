protocol DIContainerProtocol {
    func register<T>(for type: T.Type, _ instance: T)
    func register<T>(for type: T.Type, _ factory: @escaping () -> T)
    func register<T>(for type: T.Type, _ factory: @escaping (DIContainerProtocol) -> T)
    func resolve<T>(_ type: T.Type) -> T?
}
