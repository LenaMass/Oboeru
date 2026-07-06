import Foundation
import CoreData
import Combine

class StudyViewModel: ObservableObject {
    
    @Published var currentCard: FlashCard?
    @Published var currentIndex: Int = 0
    @Published var isSessionComplete: Bool = false
    
    private var deck: [FlashCard]
    private let context = PersistenceController.shared.context
    
    var totalCards: Int { deck.count }
    var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(currentIndex) / Double(totalCards)
    }
    
    init(deck: [FlashCard]) {
        self.deck = deck
        self.currentCard = deck.first
    }
    
    func markKnown() {
        guard var card = currentCard else { return }
        card.repetitions += 1
        card.interval = calculateNextInterval(card: card)
        card.easeFactor = min(card.easeFactor + 0.1, 4.0)
        card.lastReviewDate = Date()
        card.nextReviewDate = Date().addingTimeInterval(
            Double(card.interval) * 86400
        )
        card.isKnown = card.repetitions >= 5
        saveCard(card)
        moveToNext()
    }
    
    func markForgot() {
        guard var card = currentCard else { return }
        card.repetitions = 0
        card.interval = 1
        card.easeFactor = max(card.easeFactor - 0.2, 1.3)
        card.lastReviewDate = Date()
        card.nextReviewDate = Date().addingTimeInterval(86400)
        card.isKnown = false
        saveCard(card)
        moveToNext()
    }
    
    private func calculateNextInterval(card: FlashCard) -> Int {
        switch card.repetitions {
        case 0, 1, 2, 3, 4: return 1
        case 5: return 3
        case 6: return 7
        default: return Int(Double(card.interval) * card.easeFactor)
        }
    }
    
    private func moveToNext() {
        if currentIndex + 1 < deck.count {
            currentIndex += 1
            currentCard = deck[currentIndex]
        } else {
            isSessionComplete = true
            currentCard = nil
        }
    }
    
    private func saveCard(_ card: FlashCard) {
        let request = FlashCardEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "word == %@", card.word
        )
        
        if let existing = try? context.fetch(request).first {
            existing.repetitions = Int32(card.repetitions)
            existing.interval = Int32(card.interval)
            existing.easeFactor = card.easeFactor
            existing.lastReviewDate = card.lastReviewDate
            existing.nextReviewDate = card.nextReviewDate
            existing.isKnown = card.repetitions >= 5
        } else {
            let entity = FlashCardEntity(context: context)
            entity.id = card.id
            entity.word = card.word
            entity.reading = card.reading
            entity.meaning = card.meaning
            entity.jlptLevel = card.jlptLevel
            entity.easeFactor = card.easeFactor
            entity.interval = Int32(card.interval)
            entity.repetitions = Int32(card.repetitions)
            entity.nextReviewDate = card.nextReviewDate
            entity.lastReviewDate = card.lastReviewDate
            entity.isKnown = card.repetitions >= 5
            entity.createdAt = card.createdAt
            entity.exampleSentence = ""
            entity.partOfSpeech = ""
        }
        
        PersistenceController.shared.save()
    }
}
