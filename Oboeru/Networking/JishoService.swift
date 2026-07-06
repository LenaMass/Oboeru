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
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()
    
    func search(query: String) async throws -> [JishoWord] {
        let isJapanese = containsJapanese(query)
        let url = try buildURL(for: query, isJapanese: isJapanese)
        let data = try await fetchData(from: url)
        return try decode(data)
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
    
    private func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw JishoError.badResponse
        }
        
        return data
    }
    
    private func decode(_ data: Data) throws -> [JishoWord] {
        let decoded = try JSONDecoder().decode(
            JishoResponse.self, from: data
        )
        return decoded.data
    }
    
    private func containsJapanese(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            (0x3040...0x309F).contains(scalar.value) ||
            (0x30A0...0x30FF).contains(scalar.value) ||
            (0x4E00...0x9FFF).contains(scalar.value)
        }
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
