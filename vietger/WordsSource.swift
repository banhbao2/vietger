import Foundation

/// The on-disk schema (top-level envelope for words.json)
struct WordsBundleFile: Codable {
    let dataModelVersion: Int
    let words: [Word]
}

enum WordsSource {
    /// Increment when you change the JSON schema or need data transforms.
    static let currentDataModelVersion = 1

    /// Load words.json from the main bundle and migrate if needed.
    static func loadFromBundle() -> [Word]? {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            print("⚠️ words.json not found in bundle")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(WordsBundleFile.self, from: data)
            let migrated = migrateIfNeeded(decoded)
            return migrated.words
        } catch {
            print("⚠️ Failed to load words.json: \(error)")
            return nil
        }
    }

    /// Migration pipeline — extend with version bumps when needed.
    private static func migrateIfNeeded(_ file: WordsBundleFile) -> WordsBundleFile {
        let file = file

        // Example migration chain (add concrete functions when you bump versions):
        // if file.dataModelVersion == 1 { /* nothing to do */ }
        // else if file.dataModelVersion == 0 { file = migrateV0toV1(file) }

        return file
    }

    // MARK: - Example migration stubs (fill when needed)
    // private static func migrateV0toV1(_ file: WordsBundleFile) -> WordsBundleFile {
    //     var file = file
    //     // …perform any renames, category changes, alt merges, etc.
    //     return WordsBundleFile(dataModelVersion: 1, words: file.words)
    // }
}
