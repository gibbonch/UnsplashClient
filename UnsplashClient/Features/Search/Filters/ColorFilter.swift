import Foundation

enum ColorFilter: SearchFilter, CaseIterable {
    
    case any
    case blackAndWhite
    case white
    case black
    case yellow
    case orange
    case red
    case purple
    case magenta
    case green
    case teal
    case blue
    
    var type: FilterType { .color }
    
    var value: String? {
        switch self {
        case .any: return nil
        case .blackAndWhite: return "black_and_white"
        case .white: return "white"
        case .black: return "black"
        case .yellow: return "yellow"
        case .orange: return "orange"
        case .red: return "red"
        case .purple: return "purple"
        case .magenta: return "magenta"
        case .green: return "green"
        case .teal: return "teal"
        case .blue: return "blue"
        }
    }
    
    var text: String {
        switch self {
        case .any: return "Any"
        case .blackAndWhite: return "Black and White"
        case .white: return "White"
        case .black: return "Black"
        case .yellow: return "Yellow"
        case .orange: return "Orange"
        case .red: return "Red"
        case .purple: return "Purple"
        case .magenta: return "Magenta"
        case .green: return "Green"
        case .teal: return "Teal"
        case .blue: return "Blue"
        }
    }
    
    var hex: [String] {
        switch self {
        case .any: return []
        case .blackAndWhite: return ["#000000", "#FFFFFF"]
        case .white: return ["#FFFFFF"]
        case .black: return ["#000000"]
        case .yellow: return ["#FCDC00"]
        case .orange: return ["#FE9200"]
        case .red: return ["#F44E3B"]
        case .purple: return ["#7B64FF"]
        case .magenta: return ["#AB149E"]
        case .green: return ["#A4DD00"]
        case .teal: return ["#68CCCA"]
        case .blue: return ["#009CE0"]
        }
    }
    
    static func hex(for value: String) -> [String] {
        return ColorFilter.allCases.first { $0.value == value }?.hex ?? []
    }
}
