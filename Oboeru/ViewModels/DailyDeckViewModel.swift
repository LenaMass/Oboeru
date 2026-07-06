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
                print("✅ Loaded \(cards.count) cards from Core Data")
            }
            return
        }
        generateNewDeck()
    }

    func generateNewDeck() {
        isLoading = true
        errorMessage = nil

        let seenWords = fetchSeenWords()
        print("🔍 Seen words: \(seenWords.count)")

        Task {
            do {
                print("🌐 Fetching from JLPT API...")
                let words = try await jlptService.fetchDailyDeck(
                    seenWords: seenWords
                )
                print("✅ Fetched \(words.count) words")
                words.forEach {
                    print("   \($0.word) / \($0.reading) / \($0.meaning)")
                }

                let cards = words.map { FlashCard(jlptWord: $0) }

                await MainActor.run {
                    saveDailyDeck(cards: cards, words: words)
                    todaysDeck = cards
                    isLoading = false
                    print("📱 Deck set: \(todaysDeck.count) cards")
                }
            } catch {
                print("❌ Error: \(error.localizedDescription)")
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
        isCompleted = true
        PersistenceController.shared.save()
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
        }

        PersistenceController.shared.save()
    }

    private func containsKanji(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x4E00...0x9FFF).contains(scalar.value)
        }
    }
}
