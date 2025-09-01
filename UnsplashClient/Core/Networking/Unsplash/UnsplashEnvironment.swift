import Foundation

enum UnsplashEnvironment {
    
    enum Keys {
        static let baseUrl = "BASE_URL"
        static let accesKey = "ACCESS_KEY"
    }
    
    static let baseURL: URL = {
        guard let stringURL = info[Keys.baseUrl] as? String,
              let url = URL(string: stringURL) else {
            fatalError("Base URL not set in plist")
        }
        return url
    }()
    
    static let accessKey: String = {
        guard let key = info[Keys.accesKey] as? String else {
            fatalError("Access key not set in plist")
        }
        return key
    }()
    
    private static let info: [String: Any] = {
        guard let info = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return info
    }()
}
