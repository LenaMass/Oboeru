import Foundation

struct JLPTWord: Codable, Identifiable {
    let id = UUID()
    let word: String
    let meaning: String
    let furigana: String
    let romaji: String
    let level: Int

    var isKanaWord: Bool { furigana.isEmpty }
    var reading: String { furigana.isEmpty ? word : furigana }

    enum CodingKeys: String, CodingKey {
        case word, meaning, furigana, romaji, level
    }
}

struct JLPTResponse: Codable {
    let total: Int?
    let words: [JLPTWord]
}

enum JLPTError: LocalizedError {
    case invalidURL
    case badResponse
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Could not build the request URL"
        case .badResponse: return "No response — check your connection"
        }
    }
}

class JLPTVocabService {
    
    static let shared = JLPTVocabService()
    
    private let baseURL = "https://jlpt-vocab-api.vercel.app/api/words"
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()
    
    func fetchDailyDeck(seenWords: Set<String>) async throws -> [JLPTWord] {
        guard let url = URL(
            string: "\(baseURL)/all?level=5"
        ) else {
            throw JLPTError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw JLPTError.badResponse
        }
        
        let allWords = try JSONDecoder().decode([JLPTWord].self, from: data)
        
        let unseen = allWords
            .filter { !seenWords.contains($0.word) }
            .shuffled()
        
        var kanaWords: [JLPTWord] = []
        var kanjiWords: [JLPTWord] = []
        
        for word in unseen {
            if kanaWords.count < 5 && word.isKanaWord {
                kanaWords.append(word)
            } else if kanjiWords.count < 5 && !word.isKanaWord {
                kanjiWords.append(word)
            }
            if kanaWords.count == 5 && kanjiWords.count == 5 { break }
        }
        
        return kanaWords + kanjiWords
    }
}
