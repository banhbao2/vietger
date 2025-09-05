import Foundation

/// The on-disk schema (top-level envelope for words JSON files)
struct WordsBundleFile: Codable {
    let dataModelVersion: Int
    let words: [Word]
}

enum WordsSource {
    static let currentDataModelVersion = 1

    /// Core deck (words.json)
    static func loadFromBundle() -> [Word]? {
        load(resource: "words")
    }

    /// Vyvu deck (vyvu_words.json)
    static func loadVyvuFromBundle() -> [Word]? {
        load(resource: "vyvu_words")
    }

    // MARK: - Core loader
    private static func load(resource: String) -> [Word]? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            print("⚠️ \(resource).json not found in bundle")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(WordsBundleFile.self, from: data)
            let migrated = migrateIfNeeded(decoded)
            return migrated.words
        } catch {
            print("⚠️ Failed to load \(resource).json: \(error)")
            return nil
        }
    }

    private static func migrateIfNeeded(_ file: WordsBundleFile) -> WordsBundleFile {
        var file = file
        // future migrations here
        return file
    }
}
