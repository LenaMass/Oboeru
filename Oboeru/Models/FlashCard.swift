import Foundation

struct FlashCard: Identifiable, Codable {

    let id : UUID
    var word : String
    var reading : String
    var meaning : String
    var exampleSentence : String
    var jlptLevel : String
    var partOfSpeech : String
    
    var easeFactor: Double
    var interval: Int
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date?
    var isKnown: Bool
    
    var createdAt: Date

    
    init(word: String,
             reading: String,
             meaning: String,
             exampleSentence: String = "",
             jlptLevel: String = "",
             partOfSpeech: String = "") {
            self.id = UUID()
            self.word = word
            self.reading = reading
            self.meaning = meaning
            self.exampleSentence = exampleSentence
            self.jlptLevel = jlptLevel
            self.partOfSpeech = partOfSpeech
            
            self.easeFactor = 2.5
            self.interval = 1
            self.repetitions = 0
            self.nextReviewDate = Date()
            self.lastReviewDate = nil
            self.isKnown = false
            self.createdAt = Date()
        }
        
        var isDueToday: Bool {
            nextReviewDate <= Date()
        }
    }
extension FlashCard {
    init(jlptWord: JLPTWord) {
        self.id = UUID()
        self.word = jlptWord.word
        self.reading = jlptWord.reading
        self.meaning = jlptWord.meaning
        self.exampleSentence = ""
        self.jlptLevel = "N\(jlptWord.level)"
        self.partOfSpeech = ""
        self.easeFactor = 2.5
        self.interval = 1
        self.repetitions = 0
        self.nextReviewDate = Date()
        self.lastReviewDate = nil
        self.isKnown = false
        self.createdAt = Date()
    }
}
