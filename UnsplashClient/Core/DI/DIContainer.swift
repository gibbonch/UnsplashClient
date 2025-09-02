import Foundation

final class DIContainer: DIContainerProtocol {
    
    var parent: DIContainerProtocol?
    
    private var instances: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    private let lock = NSRecursiveLock()
    
    func register<T>(for type: T.Type, _ instance: T) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        
        instances[key] = instance
        factories.removeValue(forKey: key)
    }
    
    func register<T>(for type: T.Type, _ factory: @escaping () -> T) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        
        factories[key] = factory
        instances.removeValue(forKey: key)
    }
    
    func register<T>(for type: T.Type, _ factory: @escaping (DIContainerProtocol) -> T) {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        
        factories[key] = { [weak self] in
            guard let self else { fatalError("DIContainer is deallocated") }
            return factory(self)
        }
        instances.removeValue(forKey: key)
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        lock.lock()
        defer { lock.unlock() }
        
        if let instance = instances[key] as? T {
            return instance
        }
        
        if let factory = factories[key] {
            let instance = factory()
            return instance as? T
        }
        
        if let instance = parent?.resolve(type) {
            return instance
        }
        
        return nil
    }
}
