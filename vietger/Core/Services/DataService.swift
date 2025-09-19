import Foundation

final class DataService {
    private let decoder = JSONDecoder()
    // Raw map as loaded (exact wordId string as key)
    private var sentencesCache: [String: Sentence] = [:]
    // Normalized map to be resilient to case/diacritics/articles differences
    private var normalizedSentencesCache: [String: Sentence] = [:]
    
    init() {
        loadAllSentences()
    }
    
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
    
    // Load sentences from JSON files
    private func loadAllSentences() {
        sentencesCache.removeAll()
        normalizedSentencesCache.removeAll()
        
        // Load core sentences
        if let sentences = loadSentencesFromFile(for: .core) {
            index(sentences)
        }
        
        // Load vyvu sentences
        if let sentences = loadSentencesFromFile(for: .vyvu) {
            index(sentences)
        }
    }
    
    private func loadSentencesFromFile(for deck: DeckType) -> [Sentence]? {
        let resource = deck == .core ? "sentences_core" : "sentences_vyvu"
        
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            print("⚠️ \(resource).json not found")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url),
              let file = try? decoder.decode(SentencesDataFile.self, from: data) else {
            print("⚠️ Failed to decode \(resource).json")
            return nil
        }
        
        return file.sentences
    }
    
    // Index sentences into both exact and normalized caches
    private func index(_ sentences: [Sentence]) {
        for s in sentences {
            // Exact key as given
            sentencesCache[s.wordId] = s
            
            // Normalized key
            let raw = s.wordId
            let base = normalize(raw)
            normalizedSentencesCache[base] = s
            
            // If wordId contains a leading article, index without it as well
            if let withoutArticle = dropLeadingArticle(from: raw) {
                let normalizedNoArticle = normalize(withoutArticle)
                normalizedSentencesCache[normalizedNoArticle] = s
            }
        }
    }
    
    // Updated: Try multiple keys to find a sentence robustly
    func getSentence(for word: Word) -> Sentence? {
        // 1) Prefer exact id match (works when words and sentences share explicit ids)
        if let s = sentencesCache[word.id] {
            return s
        }
        
        // 2) Try exact German
        if let s = sentencesCache[word.german] {
            return s
        }
        
        // 3) Try alternatives exact
        for alt in word.germanAlt {
            if let s = sentencesCache[alt] {
                return s
            }
        }
        
        // 4) Normalized matching: id, german, drop-article variants, alternatives
        let candidates = candidateKeys(for: word)
        for key in candidates {
            if let s = normalizedSentencesCache[key] {
                return s
            }
        }
        
        return nil
    }
    
    // Build a set of normalized candidate keys for the word
    private func candidateKeys(for word: Word) -> [String] {
        var keys: Set<String> = []
        
        // Base forms
        keys.insert(normalize(word.id))
        keys.insert(normalize(word.german))
        
        // Drop leading article from german if present
        if let noArticle = dropLeadingArticle(from: word.german) {
            keys.insert(normalize(noArticle))
        }
        
        // Alternatives
        for alt in word.germanAlt {
            keys.insert(normalize(alt))
            if let noArt = dropLeadingArticle(from: alt) {
                keys.insert(normalize(noArt))
            }
        }
        
        return Array(keys)
    }
    
    // Normalize: lowercase, trim, strip diacritics, collapse spaces
    private func normalize(_ s: String) -> String {
        let lowered = s.lowercased()
        let trimmed = lowered.trimmingCharacters(in: .whitespacesAndNewlines)
        let folded = trimmed.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: .current)
        // Replace multiple spaces with single space
        let collapsed = folded.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return collapsed
    }
    
    // Remove a single leading German article if present
    private func dropLeadingArticle(from s: String) -> String? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        guard parts.count > 1 else { return nil }
        let first = String(parts[0]).lowercased()
        switch first {
        case "der", "die", "das", "ein", "eine", "einen", "einem", "einer", "dem", "den", "des":
            return String(parts[1])
        default:
            return nil
        }
    }
}

// Renamed to avoid conflict
struct WordsDataFile: Codable {
    let dataModelVersion: Int
    let words: [Word]
}
