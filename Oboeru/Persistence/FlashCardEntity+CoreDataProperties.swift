
public import Foundation
public import CoreData


public typealias FlashCardEntityCoreDataPropertiesSet = NSSet

extension FlashCardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlashCardEntity> {
        return NSFetchRequest<FlashCardEntity>(entityName: "FlashCardEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var word: String?
    @NSManaged public var reading: String?
    @NSManaged public var meaning: String?
    @NSManaged public var exampleSentence: String?
    @NSManaged public var jlptLevel: String?
    @NSManaged public var partOfSpeech: String?
    @NSManaged public var slug: String?
    @NSManaged public var easeFactor: Double
    @NSManaged public var interval: Int32
    @NSManaged public var repetitions: Int32
    @NSManaged public var nextReviewDate: Date?
    @NSManaged public var lastReviewDate: Date?
    @NSManaged public var isKnown: Bool
    @NSManaged public var createdAt: Date?

}

extension FlashCardEntity : Identifiable {

}
