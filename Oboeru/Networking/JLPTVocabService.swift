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
        var kanaWords: [JLPTWord] = []
        var kanjiWords: [JLPTWord] = []
        var offset = Int.random(in: 0..<300)
        var attempts = 0

        while (kanaWords.count < 5 || kanjiWords.count < 5) && attempts < 10 {
            guard let url = URL(
                string: "\(baseURL)?level=5&offset=\(offset)&limit=50"
            ) else { break }

            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw JLPTError.badResponse
            }

            let decoded = try JSONDecoder().decode(
                JLPTResponse.self, from: data
            )

            let unseen = decoded.words.filter {
                !seenWords.contains($0.word)
            }

            for word in unseen {
                if kanaWords.count < 5 &&
                   word.isKanaWord &&
                   !kanaWords.contains(where: { $0.word == word.word }) {
                    kanaWords.append(word)
                } else if kanjiWords.count < 5 &&
                          !word.isKanaWord &&
                          !kanjiWords.contains(where: { $0.word == word.word }) {
                    kanjiWords.append(word)
                }
                if kanaWords.count == 5 && kanjiWords.count == 5 { break }
            }

            offset += 50
            attempts += 1
        }

        return kanaWords + kanjiWords
    }
}
