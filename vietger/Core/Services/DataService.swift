import Foundation

final class DataService {
    private let decoder = JSONDecoder()
    
    func loadWords(for deck: DeckType) -> [Word] {
        let resource = deck == .core ? "words" : "vyvu_words"
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? decoder.decode(WordsDataFile.self, from: data) else {
            print("⚠️ Failed to load \(resource).json")
            return []
        }
        return file.words
    }
    
    func preloadAllData() -> (core: [Word], vyvu: [Word]) {
        return (loadWords(for: .core), loadWords(for: .vyvu))
    }
}

// Renamed to avoid conflict
struct WordsDataFile: Codable {
    let dataModelVersion: Int
    let words: [Word]
}
