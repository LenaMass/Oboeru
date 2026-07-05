

public import Foundation
public import CoreData


public typealias DailyDeckEntityCoreDataPropertiesSet = NSSet

extension DailyDeckEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyDeckEntity> {
        return NSFetchRequest<DailyDeckEntity>(entityName: "DailyDeckEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var wordSlugs: String?
    @NSManaged public var isCompleted: Bool

}

extension DailyDeckEntity : Identifiable {

}
