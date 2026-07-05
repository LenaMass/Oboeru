import Foundation

struct JishoResponse: Codable {
    let data: [JishoWord]
}

struct JishoWord: Codable, Identifiable {
    let id = UUID()
    let slug: String
    let jlpt: [String]
    let japanese: [JishoJapanese]
    let senses: [JishoSense]
    
    var primaryWord: String {
        japanese.first?.word ?? japanese.first?.reading ?? slug
    }
    
    var primaryReading: String {
        japanese.first?.reading ?? ""
    }
    
    var primaryMeaning: String {
        senses.first?.englishDefinitions.first ?? ""
    }
    
    var allMeanings: [String] {
        senses.first?.englishDefinitions ?? []
    }
    
    var jlptLevel: String {
        jlpt.first ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case slug
        case jlpt
        case japanese
        case senses
    }
}

struct JishoJapanese: Codable {
    let word: String?
    let reading: String?
}

struct JishoSense: Codable {
    let englishDefinitions: [String]
    let partsOfSpeech: [String]
    
    enum CodingKeys: String, CodingKey {
        case englishDefinitions = "english_definitions"
        case partsOfSpeech = "parts_of_speech"
    }
}
