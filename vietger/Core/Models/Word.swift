import Foundation

struct Word: Identifiable, Hashable, Codable {
    let german: String
    let germanAlt: [String]
    let vietnamese: String
    let vietnameseAlt: [String]
    let category: Category

    // Backing storage for decoded id (optional, to support legacy files without id)
    private let decodedId: String?

    // Public id prefers decoded value; falls back to synthesized scheme
    var id: String {
        if let decodedId, !decodedId.isEmpty {
            return decodedId
        }
        return "\(german)→\(vietnamese)"
    }

    var allGerman: [String] { [german] + germanAlt }
    var allVietnamese: [String] { [vietnamese] + vietnameseAlt }
}

// New Sentence model
struct Sentence: Codable {
    let wordId: String
    let german: String
    let vietnamese: String
}

struct SentencesDataFile: Codable {
    let dataModelVersion: Int
    let sentences: [Sentence]
}

// MARK: - Codable
extension Word {
    private enum CodingKeys: String, CodingKey {
        case id
        case german
        case germanAlt
        case vietnamese
        case vietnameseAlt
        case category
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // Optional id for forward-compatible, stable identifiers
        self.decodedId = try c.decodeIfPresent(String.self, forKey: .id)
        self.german = try c.decode(String.self, forKey: .german)
        self.germanAlt = try c.decodeIfPresent([String].self, forKey: .germanAlt) ?? []
        self.vietnamese = try c.decode(String.self, forKey: .vietnamese)
        self.vietnameseAlt = try c.decodeIfPresent([String].self, forKey: .vietnameseAlt) ?? []
        self.category = try c.decode(Category.self, forKey: .category)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        // Encode the resolved id so it round-trips consistently
        try c.encode(id, forKey: .id)
        try c.encode(german, forKey: .german)
        try c.encode(germanAlt, forKey: .germanAlt)
        try c.encode(vietnamese, forKey: .vietnamese)
        try c.encode(vietnameseAlt, forKey: .vietnameseAlt)
        try c.encode(category, forKey: .category)
    }
}
