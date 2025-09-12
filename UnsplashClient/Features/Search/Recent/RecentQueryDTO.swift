import Foundation
import CoreData

@objc(RecentQueryDTO)
public class RecentQueryDTO: NSManagedObject {
    
    struct FilterData: Codable {
        let type: String
        let value: String
    }
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RecentQueryDTO> {
        return NSFetchRequest<RecentQueryDTO>(entityName: "RecentQueryDTO")
    }
    
    @NSManaged public var identifier: String?
    @NSManaged public var text: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var filtersData: Data?
    
    convenience init(query: SearchQuery, context: NSManagedObjectContext) {
        self.init(context: context)
        identifier = UUID().uuidString
        text = query.text
        timestamp = Date()
        filtersData = try? JSONEncoder().encode(query.filters.map {
            FilterData(type: $0.type.rawValue, value: $0.value ?? "nil")
        })
    }
    
    func mapToDomain() -> SearchQuery? {
        guard let text = text else {
            return nil
        }
        
        let filters: [any SearchFilter]
        
        guard let filtersData = filtersData,
              let filterDataArray = try? JSONDecoder().decode([FilterData].self, from: filtersData) else {
            return nil
        }
        
        filters = filterDataArray.compactMap { filterData in
            guard let filterType = FilterType(rawValue: filterData.type) else {
                return nil
            }
            
            switch filterType {
            case .orderedBy:
                return OrderedByFilter.allCases.first { $0.value == filterData.value }
                
            case .orientation:
                let actualValue = filterData.value == "nil" ? nil : filterData.value
                
                if actualValue == nil {
                    return OrientationFilter.any
                }
                return OrientationFilter.allCases.first { $0.value == actualValue }
            case .color:
                let actualValue = filterData.value == "nil" ? nil : filterData.value
                
                if actualValue == nil {
                    return ColorFilter.any
                }
                return ColorFilter.allCases.first { $0.value == actualValue }
            }
        }
        
        return SearchQuery(text: text, filters: filters)
    }
}

extension RecentQueryDTO: Identifiable { }
