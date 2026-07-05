import Foundation
import Combine

class SearchViewModel: ObservableObject {
    
    @Published var results: [JishoWord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hasSearched: Bool = false
    
    private let service = JishoService.shared
    
    func search(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        hasSearched = true
        results = []
        
        Task {
            do {
                let words = try await service.search(query: query)
                let filtered = filterAndRank(words, query: query)
                await MainActor.run {
                    results = filtered
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
    
    func clearSearch() {
        results = []
        errorMessage = nil
        hasSearched = false
        isLoading = false
    }
    
    private func filterAndRank(_ words: [JishoWord],
                                query: String) -> [JishoWord] {
        let isJapanese = containsJapanese(query)
        
        var filtered = words.filter { word in
            if isJapanese { return true }
            
            let meaning = word.primaryMeaning.lowercased()
            let queryLower = query.lowercased()
            
            let hasMeaningMatch = meaning.contains(queryLower)
            let hasJLPT = !word.jlpt.isEmpty
            let isNotProperNoun = !(word.senses.first?.partsOfSpeech.contains("Wikipedia definition") == true)
            
            return hasMeaningMatch || hasJLPT && isNotProperNoun
        }
        
        filtered.sort { a, b in
            let aHasJLPT = !a.jlpt.isEmpty
            let bHasJLPT = !b.jlpt.isEmpty
            
            if aHasJLPT && !bHasJLPT { return true }
            if !aHasJLPT && bHasJLPT { return false }
            
            let aLevel = jlptRank(a.jlptLevel)
            let bLevel = jlptRank(b.jlptLevel)
            return aLevel < bLevel
        }
        
        return filtered
    }
    
    private func jlptRank(_ level: String) -> Int {
        switch level {
        case "jlpt-n5": return 1
        case "jlpt-n4": return 2
        case "jlpt-n3": return 3
        case "jlpt-n2": return 4
        case "jlpt-n1": return 5
        default: return 6
        }
    }
    
    private func containsJapanese(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x3040...0x309F).contains(scalar.value) ||
            (0x30A0...0x30FF).contains(scalar.value) ||
            (0x4E00...0x9FFF).contains(scalar.value)
        }
    }
}
