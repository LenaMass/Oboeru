import Foundation

enum JishoError: LocalizedError {
    case invalidQuery
    case invalidURL
    case badResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery: return "Please enter a valid search term"
        case .invalidURL:   return "Could not build the search URL"
        case .badResponse:  return "No response from Jisho — check your connection"
        }
    }
}

class JishoService {
    static let shared = JishoService()
    
    private let baseURL = "https://jisho.org/api/v1/search/words"
    
    func search(query: String) async throws -> [JishoWord] {
        let isJapanese = containsJapanese(query)
        let url = try buildURL(for: query, isJapanese: isJapanese)
        let data = try await fetchData(from: url)
        return try decode(data)
    }

    private func containsJapanese(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x3040...0x309F).contains(scalar.value) ||
            (0x30A0...0x30FF).contains(scalar.value) ||
            (0x4E00...0x9FFF).contains(scalar.value)
        }
    }
    private func buildURL(for query: String,
                          isJapanese: Bool) throws -> URL {
        guard !query.isEmpty else {
            throw JishoError.invalidQuery
        }
        
        let searchQuery = isJapanese ? query : "\(query) #jlpt"
        
        guard let encodedQuery = searchQuery.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) else {
            throw JishoError.invalidQuery
        }
        
        guard let url = URL(
            string: "\(baseURL)?keyword=\(encodedQuery)"
        ) else {
            throw JishoError.invalidURL
        }
        
        return url
   
    }
    func fetchDailyKanaWords(page: Int = 1) async throws -> [JishoWord] {
        let query = "%23jlpt-n5%20%23common"
        guard let url = URL(
            string: "\(baseURL)?keyword=\(query)&page=\(page)"
        ) else {
            throw JishoError.invalidURL
        }
        
        let data = try await fetchData(from: url)
        let words = try decode(data)
        
        return words.filter { word in
            let primaryWord = word.primaryWord
            let reading = word.primaryReading
            return (isKanaOnly(primaryWord) || isKanaOnly(reading))
                && !primaryWord.isEmpty
                && !containsKanji(primaryWord)
        }
    }

    func fetchDailyKanjiWords(page: Int = 1) async throws -> [JishoWord] {
        let query = "%23jlpt-n5%20%23common"
        guard let url = URL(
            string: "\(baseURL)?keyword=\(query)&page=\(page)"
        ) else {
            throw JishoError.invalidURL
        }
        
        let data = try await fetchData(from: url)
        let words = try decode(data)
        
        return words.filter { word in
            let primaryWord = word.primaryWord
            return containsKanji(primaryWord) && !primaryWord.isEmpty
        }
    }

    func fetchDailyDeck(seenSlugs: Set<String>) async throws -> [JishoWord] {
        var kanaWords: [JishoWord] = []
        var kanjiWords: [JishoWord] = []
        var page = 1
        
        while kanaWords.count < 5 || kanjiWords.count < 5 {
            if kanaWords.count < 5 {
                let fetched = try await fetchDailyKanaWords(page: page)
                let unseen = fetched.filter { !seenSlugs.contains($0.slug) }
                kanaWords.append(contentsOf: unseen.prefix(5 - kanaWords.count))
            }
            
            if kanjiWords.count < 5 {
                let fetched = try await fetchDailyKanjiWords(page: page)
                let unseen = fetched.filter { !seenSlugs.contains($0.slug) }
                kanjiWords.append(contentsOf: unseen.prefix(5 - kanjiWords.count))
            }
            
            page += 1
            if page > 10 { break }
        }
        
        return Array((kanaWords + kanjiWords).prefix(10))
    }

    private func isKanaOnly(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        return text.unicodeScalars.allSatisfy { scalar in
            (0x3040...0x309F).contains(scalar.value) ||
            (0x30A0...0x30FF).contains(scalar.value)
        }
    }

    private func containsKanji(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x4E00...0x9FFF).contains(scalar.value)
        }
    }
    }
private func fetchData(from url:URL) async throws -> Data {
    let (data, response) = try await URLSession.shared.data (from:url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw JishoError.badResponse
    }
    return data
}
private func decode(_ data: Data) throws -> [JishoWord] {
        let decoded = try JSONDecoder().decode(JishoResponse.self, from: data)
        return decoded.data
    }

