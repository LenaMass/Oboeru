import Foundation
import CoreData
import Combine

class DailyDeckViewModel: ObservableObject {
    
    @Published var todaysDeck: [FlashCard] = []
    @Published var isLoading: Bool = false
    @Published var isCompleted: Bool = false
    @Published var errorMessage: String? = nil
    
    private let context = PersistenceController.shared.context
    private let jlptService = JLPTVocabService.shared
    
    var kanaCount: Int {
        todaysDeck.filter { !containsKanji($0.word) }.count
    }
    
    var kanjiCount: Int {
        todaysDeck.filter { containsKanji($0.word) }.count
    }
    
    init() {
        loadOrGenerateDeck()
    }
    
    func loadOrGenerateDeck() {
        if let existing = fetchTodaysDeck() {
            isCompleted = existing.isCompleted
            if let jsonString = existing.wordsJSON,
               let jsonData = jsonString.data(using: .utf8),
               let cards = try? JSONDecoder().decode(
                [FlashCard].self, from: jsonData
               ) {
                todaysDeck = cards
            }
            return
        }
        generateNewDeck()
    }
    
    func generateNewDeck() {
        guard fetchTodaysDeck() == nil else {
            loadOrGenerateDeck()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let seenWords = fetchSeenWords()
        
        Task {
            do {
                let words = try await jlptService.fetchDailyDeck(
                    seenWords: seenWords
                )
                let cards = words.map { FlashCard(jlptWord: $0) }
                
                await MainActor.run {
                    saveDailyDeck(cards: cards, words: words)
                    todaysDeck = cards
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    func markDeckCompleted() {
        guard let deck = fetchTodaysDeck() else { return }
        deck.isCompleted = true
        PersistenceController.shared.save()
        DispatchQueue.main.async {
            self.isCompleted = true
        }
    }
    
    private func fetchTodaysDeck() -> DailyDeckEntity? {
        let request = DailyDeckEntity.fetchRequest()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(
            byAdding: .day, value: 1, to: today
        )!
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            today as CVarArg,
            tomorrow as CVarArg
        )
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    private func fetchSeenWords() -> Set<String> {
        let request = SeenWordEntity.fetchRequest()
        let results = (try? context.fetch(request)) ?? []
        return Set(results.compactMap { $0.slug })
    }
    
    private func saveDailyDeck(cards: [FlashCard],
                                words: [JLPTWord]) {
        guard fetchTodaysDeck() == nil else { return }
        
        let deck = DailyDeckEntity(context: context)
        deck.date = Calendar.current.startOfDay(for: Date())
        deck.wordSlugs = words.map { $0.word }.joined(separator: ",")
        deck.isCompleted = false
        
        if let jsonData = try? JSONEncoder().encode(cards),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            deck.wordsJSON = jsonString
        }
        
        for word in words {
            let seen = SeenWordEntity(context: context)
            seen.slug = word.word
            seen.seenAt = Date()
            
            let cardRequest = FlashCardEntity.fetchRequest()
            cardRequest.predicate = NSPredicate(
                format: "word == %@", word.word
            )
            
            if (try? context.fetch(cardRequest).first) == nil {
                let entity = FlashCardEntity(context: context)
                entity.id = UUID()
                entity.word = word.word
                entity.reading = word.reading
                entity.meaning = word.meaning
                entity.jlptLevel = "N\(word.level)"
                entity.exampleSentence = ""
                entity.partOfSpeech = ""
                entity.easeFactor = 2.5
                entity.interval = 1
                entity.repetitions = 0
                entity.nextReviewDate = Date()
                entity.lastReviewDate = nil
                entity.isKnown = false
                entity.createdAt = Date()
            }
        }
        
        PersistenceController.shared.save()
    }
    
    private func containsKanji(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x4E00...0x9FFF).contains(scalar.value)
        }
    }
}
