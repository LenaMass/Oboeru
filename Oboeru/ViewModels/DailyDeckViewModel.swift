import Foundation
import CoreData
import Combine

class DailyDeckViewModel: ObservableObject {
    
    @Published var todaysDeck: [JishoWord] = []
    @Published var isLoading: Bool = false
    @Published var isCompleted: Bool = false
    @Published var errorMessage: String? = nil
    
    private let context = PersistenceController.shared.context
    private let service = JishoService.shared
    
    init() {
        loadOrGenerateDeck()
    }
    
    func loadOrGenerateDeck() {
        if let existing = fetchTodaysDeck() {
            isCompleted = existing.isCompleted
            let slugs = existing.wordSlugs?
                .components(separatedBy: ",") ?? []
            
            if !slugs.isEmpty {
                isLoading = true
                Task {
                    do {
                        var loadedWords: [JishoWord] = []
                        for slug in slugs.prefix(10) {
                            let results = try await service.search(
                                query: slug
                            )
                            if let match = results.first(where: {
                                $0.slug == slug
                            }) {
                                loadedWords.append(match)
                            }
                        }
                        await MainActor.run {
                            todaysDeck = loadedWords
                            isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            isLoading = false
                            todaysDeck = []
                        }
                    }
                }
            }
            return
        }
        generateNewDeck()
    }
    
    func generateNewDeck() {
        isLoading = true
        errorMessage = nil
        
        let seenSlugs = fetchSeenSlugs()
        
        Task {
            do {
                let words = try await service.fetchDailyDeck(
                    seenSlugs: seenSlugs
                )
                
                await MainActor.run {
                    saveDailyDeck(words: words)
                    todaysDeck = words
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
    
    private func fetchSeenSlugs() -> Set<String> {
        let request = SeenWordEntity.fetchRequest()
        let results = (try? context.fetch(request)) ?? []
        return Set(results.compactMap { $0.slug })
    }
    
    private func saveDailyDeck(words: [JishoWord]) {
        let deck = DailyDeckEntity(context: context)
        deck.date = Calendar.current.startOfDay(for: Date())
        deck.wordSlugs = words.map { $0.slug }.joined(separator: ",")
        deck.isCompleted = false
        
        for word in words {
            let seen = SeenWordEntity(context: context)
            seen.slug = word.slug
            seen.seenAt = Date()
        }
        
        PersistenceController.shared.save()
    }
}
