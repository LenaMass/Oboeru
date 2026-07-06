
public import Foundation
public import CoreData


public typealias SeenWordEntityCoreDataPropertiesSet = NSSet

extension SeenWordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SeenWordEntity> {
        return NSFetchRequest<SeenWordEntity>(entityName: "SeenWordEntity")
    }

    @NSManaged public var seenAt: Date?
    @NSManaged public var slug: String?

}

extension SeenWordEntity : Identifiable {

}
