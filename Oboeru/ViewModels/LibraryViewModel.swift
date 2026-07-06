import Foundation
import CoreData
import Combine

class LibraryViewModel: ObservableObject {
    
    @Published var dueCards: [FlashCard] = []
    @Published var allCards: [FlashCard] = []
    
    private let context = PersistenceController.shared.context
    private var cancellables = Set<AnyCancellable>()
    
    var dueCount: Int { dueCards.count }
    var totalCount: Int { allCards.count }
    
    init() {
        fetchCards()
        observeChanges()
    }
    
    private func observeChanges() {
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange,
                       object: context)
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchCards()
            }
            .store(in: &cancellables)
    }
    
    func fetchCards() {
        let request = FlashCardEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \FlashCardEntity.createdAt,
                ascending: false
            )
        ]
        
        let entities = (try? context.fetch(request)) ?? []
        
        allCards = entities.compactMap { entity in
            guard let word = entity.word,
                  let reading = entity.reading,
                  let meaning = entity.meaning else {
                return nil
            }
            
            var card = FlashCard(
                word: word,
                reading: reading,
                meaning: meaning,
                jlptLevel: entity.jlptLevel ?? ""
            )
            card.easeFactor = entity.easeFactor
            card.interval = Int(entity.interval)
            card.repetitions = Int(entity.repetitions)
            card.nextReviewDate = entity.nextReviewDate ?? Date()
            card.lastReviewDate = entity.lastReviewDate
            card.isKnown = entity.isKnown
            return card
        }
        
        dueCards = allCards.filter { $0.isDueToday }
    }
}
