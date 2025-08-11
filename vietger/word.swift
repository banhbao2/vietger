import Foundation

// MARK: - Category

enum Category: String, CaseIterable, Hashable {
    case pronouns
    case coreVerbs
    case nouns
    case commonThings
    case adjectives
    case questionWords
    case timeFrequency
    case prepositions
    case connectors
    case adverbsFillers
    case interjectionsExpressions
    case other

    var title: String {
        switch self {
        case .pronouns: return "Pronouns & Personal Words"
        case .coreVerbs: return "Core Verbs"
        case .nouns: return "Nouns (People, Time, Places)"
        case .commonThings: return "Common Things"
        case .adjectives: return "Adjectives"
        case .questionWords: return "Question Words"
        case .timeFrequency: return "Time & Frequency"
        case .prepositions: return "Prepositions"
        case .connectors: return "Connectors"
        case .adverbsFillers: return "Common Adverbs & Fillers"
        case .interjectionsExpressions: return "Basic Interjections & Expressions"
        case .other: return "Other"
        }
    }

    /// Preferred section order for UI
    static let ordered: [Category] = [
        .pronouns, .coreVerbs, .nouns, .commonThings,
        .adjectives, .questionWords, .timeFrequency,
        .prepositions, .connectors, .adverbsFillers,
        .interjectionsExpressions, .other
    ]
}

// MARK: - Model

/// Supports multiple acceptable answers both ways.
/// Includes `category` so views don’t need to guess it.
struct Word: Identifiable, Hashable {
    let german: String
    let germanAlt: [String]
    let vietnamese: String
    let vietnameseAlt: [String]
    let category: Category

    /// Stable ID based on canonical forms (unchanged -> progress safe)
    var id: String { "\(german)↔\(vietnamese)" }

    /// Convenience for quiz matching
    var allGerman: [String] { [german] + germanAlt }
    var allVietnamese: [String] { [vietnamese] + vietnameseAlt }
}

// MARK: - Repository

enum WordsRepository {
    /// Keep words grouped by category (single source of truth).
    /// Move entries between these arrays to change a word’s category.
    static let byCategory: [Category: [Word]] = [
        .pronouns: [
            .init(german: "ich", germanAlt: ["ich", "mich", "mir"], vietnamese: "tôi", vietnameseAlt: [], category: .pronouns),
            .init(german: "du", germanAlt: ["du"], vietnamese: "bạn", vietnameseAlt: [], category: .pronouns),
            .init(german: "er", germanAlt: ["er"], vietnamese: "anh ấy", vietnameseAlt: [], category: .pronouns),
            .init(german: "sie", germanAlt: ["sie"], vietnamese: "cô ấy", vietnameseAlt: ["họ"], category: .pronouns),
            .init(german: "es", germanAlt: ["es"], vietnamese: "nó", vietnameseAlt: [], category: .pronouns),
            .init(german: "wir", germanAlt: ["wir", "uns"], vietnamese: "chúng tôi", vietnameseAlt: [], category: .pronouns),
            .init(german: "ihr", germanAlt: ["ihr", "euch"], vietnamese: "các bạn", vietnameseAlt: [], category: .pronouns),
            .init(german: "dich", germanAlt: ["dich"], vietnamese: "bạn", vietnameseAlt: [], category: .pronouns),
            .init(german: "ihm", germanAlt: ["ihm"], vietnamese: "anh ấy", vietnameseAlt: [], category: .pronouns),
        ],
        .coreVerbs: [
            .init(german: "sein", germanAlt: ["sein"], vietnamese: "là", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "haben", germanAlt: ["haben"], vietnamese: "có", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "werden", germanAlt: ["werden"], vietnamese: "trở thành", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "können", germanAlt: ["vielleicht"], vietnamese: "có thể", vietnameseAlt: [], category: .coreVerbs), // consider removing "vielleicht"
            .init(german: "müssen", germanAlt: ["müssen"], vietnamese: "phải", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "wollen", germanAlt: ["wollen"], vietnamese: "muốn", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "sollen", germanAlt: ["sollen"], vietnamese: "nên", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "mögen", germanAlt: ["mögen", "mag"], vietnamese: "thích", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "machen", germanAlt: ["tun", "erstellen", "machen"], vietnamese: "làm", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "gehen", germanAlt: ["laufen", "verlassen", "gehen"], vietnamese: "đi", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "kommen", germanAlt: ["ankommen", "bis"], vietnamese: "đến", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "sehen", germanAlt: ["anschauen", "schauen", "gucken"], vietnamese: "nhìn", vietnameseAlt: ["xem"], category: .coreVerbs),
            .init(german: "wissen", germanAlt: ["kennen", "wissen"], vietnamese: "biết", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "sagen", germanAlt: ["mitteilen", "reden"], vietnamese: "nói", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "geben", germanAlt: ["überreichen", "übergeben"], vietnamese: "đưa", vietnameseAlt: ["cho"], category: .coreVerbs),
            .init(german: "nehmen", germanAlt: ["greifen"], vietnamese: "lấy", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "finden", germanAlt: ["entdecken"], vietnamese: "tìm thấy", vietnameseAlt: ["phát hiện"], category: .coreVerbs),
            .init(german: "bleiben", germanAlt: ["verweilen"], vietnamese: "ở lại", vietnameseAlt: ["lưu lại"], category: .coreVerbs),
            .init(german: "stehen", germanAlt: ["sich befinden"], vietnamese: "đứng", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "liegen", germanAlt: ["sich befinden"], vietnamese: "nằm", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "heißen", germanAlt: ["bedeuten"], vietnamese: "tên là", vietnameseAlt: ["có nghĩa là"], category: .coreVerbs),
            .init(german: "denken", germanAlt: ["überlegen"], vietnamese: "nghĩ", vietnameseAlt: ["suy nghĩ"], category: .coreVerbs),
            .init(german: "glauben", germanAlt: ["meinen"], vietnamese: "tin", vietnameseAlt: ["cho rằng"], category: .coreVerbs),
            .init(german: "arbeiten", germanAlt: ["arbeiten"], vietnamese: "làm việc", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "spielen", germanAlt: ["spielen"], vietnamese: "chơi", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "fragen", germanAlt: ["fragen"], vietnamese: "hỏi", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "antworten", germanAlt: ["antworten"], vietnamese: "trả lời", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "leben", germanAlt: ["leben"], vietnamese: "sống", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "fahren", germanAlt: ["reisen"], vietnamese: "lái", vietnameseAlt: ["đi (phương tiện)"], category: .coreVerbs),
            .init(german: "essen", germanAlt: ["essen"], vietnamese: "ăn", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "trinken", germanAlt: ["trinken"], vietnamese: "uống", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "schreiben", germanAlt: ["schreiben"], vietnamese: "viết", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "lesen", germanAlt: ["lesen"], vietnamese: "đọc", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "brauchen", germanAlt: ["brauchen", "benötigen"], vietnamese: "cần", vietnameseAlt: [], category: .coreVerbs),
            .init(german: "versuchen", germanAlt: ["probieren", "ausprobieren"], vietnamese: "thử", vietnameseAlt: ["cố gắng"], category: .coreVerbs),
        ],
        .nouns: [
            .init(german: "der Mann", germanAlt: ["Mann", "Ehemann"], vietnamese: "người đàn ông", vietnameseAlt: [], category: .nouns),
            .init(german: "die Frau", germanAlt: ["Frau", "Ehefrau"], vietnamese: "người phụ nữ", vietnameseAlt: [], category: .nouns),
            .init(german: "das Kind", germanAlt: ["Kind"], vietnamese: "đứa trẻ", vietnameseAlt: [], category: .nouns),
            .init(german: "der Freund", germanAlt: ["Freund", "fester Freund"], vietnamese: "bạn trai", vietnameseAlt: ["bạn nam"], category: .nouns),
            .init(german: "die Freundin", germanAlt: ["Freundin", "feste Freundin"], vietnamese: "bạn gái", vietnameseAlt: ["bạn nữ"], category: .nouns),
            .init(german: "die Leute", germanAlt: ["Leute"], vietnamese: "mọi người", vietnameseAlt: [], category: .nouns),
            .init(german: "der Tag", germanAlt: ["Tag"], vietnamese: "ngày", vietnameseAlt: [], category: .nouns),
            .init(german: "die Nacht", germanAlt: ["Nacht"], vietnamese: "đêm", vietnameseAlt: [], category: .nouns),
            .init(german: "die Woche", germanAlt: ["Woche"], vietnamese: "tuần", vietnameseAlt: [], category: .nouns),
            .init(german: "der Monat", germanAlt: ["Monat"], vietnamese: "tháng", vietnameseAlt: [], category: .nouns),
            .init(german: "das Jahr", germanAlt: ["Jahr"], vietnamese: "năm", vietnameseAlt: [], category: .nouns),
            .init(german: "die Zeit", germanAlt: ["Zeit"], vietnamese: "thời gian", vietnameseAlt: [], category: .nouns),
            .init(german: "der Morgen", germanAlt: ["Morgen"], vietnamese: "buổi sáng", vietnameseAlt: [], category: .nouns),
            .init(german: "der Abend", germanAlt: ["Abend"], vietnamese: "buổi tối", vietnameseAlt: [], category: .nouns),
            .init(german: "der Ort", germanAlt: ["Ort", "Platz"], vietnamese: "nơi", vietnameseAlt: [], category: .nouns),
            .init(german: "die Stadt", germanAlt: ["Stadt"], vietnamese: "thành phố", vietnameseAlt: [], category: .nouns),
            .init(german: "das Land", germanAlt: ["Land", "Staat"], vietnamese: "đất nước", vietnameseAlt: ["quốc gia"], category: .nouns),
            .init(german: "das Haus", germanAlt: ["Haus"], vietnamese: "nhà", vietnameseAlt: [], category: .nouns),
            .init(german: "die Wohnung", germanAlt: ["Wohnung"], vietnamese: "căn hộ", vietnameseAlt: [], category: .nouns),
            .init(german: "die Arbeit", germanAlt: ["Arbeit", "Beruf"], vietnamese: "công việc", vietnameseAlt: [], category: .nouns),
            .init(german: "die Schule", germanAlt: ["Schule"], vietnamese: "trường học", vietnameseAlt: [], category: .nouns),
            .init(german: "die Straße", germanAlt: ["Straße", "Weg"], vietnamese: "đường phố", vietnameseAlt: ["con đường"], category: .nouns),
            .init(german: "der Weg", germanAlt: ["Weg", "Pfad"], vietnamese: "con đường", vietnameseAlt: ["lối đi"], category: .nouns),
            .init(german: "der Platz", germanAlt: ["Platz", "Sitzplatz"], vietnamese: "chỗ", vietnameseAlt: ["quảng trường"], category: .nouns),
            .init(german: "der Bahnhof", germanAlt: ["Bahnhof"], vietnamese: "ga tàu", vietnameseAlt: [], category: .nouns),
            .init(german: "der Flughafen", germanAlt: ["Flughafen"], vietnamese: "sân bay", vietnameseAlt: [], category: .nouns),
            .init(german: "das Geschäft", germanAlt: ["Geschäft", "Laden"], vietnamese: "cửa hàng", vietnameseAlt: [], category: .nouns),
            .init(german: "das Restaurant", germanAlt: ["Restaurant"], vietnamese: "nhà hàng", vietnameseAlt: [], category: .nouns),
            .init(german: "das Auto", germanAlt: ["Auto"], vietnamese: "xe hơi", vietnameseAlt: [], category: .nouns),
            .init(german: "der Bus", germanAlt: ["Bus"], vietnamese: "xe buýt", vietnameseAlt: [], category: .nouns),
        ],
        .commonThings: [
            .init(german: "das Geld", germanAlt: ["Geld"], vietnamese: "tiền", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Essen", germanAlt: ["Essen", "Speise"], vietnamese: "thức ăn", vietnameseAlt: ["đồ ăn"], category: .commonThings),
            .init(german: "das Getränk", germanAlt: ["Getränk", "Trunk"], vietnamese: "đồ uống", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Tisch", germanAlt: ["Tisch"], vietnamese: "bàn", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Stuhl", germanAlt: ["Stuhl"], vietnamese: "ghế", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Bett", germanAlt: ["Bett"], vietnamese: "giường", vietnameseAlt: [], category: .commonThings),
            .init(german: "die Tür", germanAlt: ["Tür"], vietnamese: "cửa", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Fenster", germanAlt: ["Fenster"], vietnamese: "cửa sổ", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Schlüssel", germanAlt: ["Schlüssel"], vietnamese: "chìa khóa", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Handy", germanAlt: ["Handy", "Mobiltelefon"], vietnamese: "điện thoại", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Computer", germanAlt: ["Computer", "Rechner"], vietnamese: "máy tính", vietnameseAlt: [], category: .commonThings),
            .init(german: "die Tasche", germanAlt: ["Tasche", "Beutel", "Tüte"], vietnamese: "túi", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Buch", germanAlt: ["Buch"], vietnamese: "sách", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Brief", germanAlt: ["Brief"], vietnamese: "thư", vietnameseAlt: [], category: .commonThings),
            .init(german: "die Zeitung", germanAlt: ["Zeitung"], vietnamese: "báo", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Film", germanAlt: ["Film", "Streifen"], vietnamese: "phim", vietnameseAlt: [], category: .commonThings),
            .init(german: "die Musik", germanAlt: ["Musik"], vietnamese: "nhạc", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Lied", germanAlt: ["Lied", "Song"], vietnamese: "bài hát", vietnameseAlt: [], category: .commonThings),
            .init(german: "das Spiel", germanAlt: ["Spiel", "Match"], vietnamese: "trò chơi", vietnameseAlt: [], category: .commonThings),
            .init(german: "der Sport", germanAlt: ["Sport"], vietnamese: "thể thao", vietnameseAlt: [], category: .commonThings),
        ],
        .adjectives: [
            .init(german: "gut", germanAlt: ["gut"], vietnamese: "tốt", vietnameseAlt: [], category: .adjectives),
            .init(german: "schlecht", germanAlt: ["hässlich"], vietnamese: "xấu", vietnameseAlt: [], category: .adjectives),
            .init(german: "groß", germanAlt: ["groß"], vietnamese: "to", vietnameseAlt: ["lớn"], category: .adjectives),
            .init(german: "klein", germanAlt: ["klein"], vietnamese: "nhỏ", vietnameseAlt: [], category: .adjectives),
            .init(german: "lang", germanAlt: ["lang"], vietnamese: "dài", vietnameseAlt: [], category: .adjectives),
            .init(german: "kurz", germanAlt: ["kurz"], vietnamese: "ngắn", vietnameseAlt: [], category: .adjectives),
            .init(german: "neu", germanAlt: ["neu"], vietnamese: "mới", vietnameseAlt: [], category: .adjectives),
            .init(german: "alt", germanAlt: ["alt"], vietnamese: "cũ", vietnameseAlt: ["già"], category: .adjectives),
            .init(german: "jung", germanAlt: ["jung"], vietnamese: "trẻ", vietnameseAlt: [], category: .adjectives),
            .init(german: "schön", germanAlt: ["schön", "hübsch"], vietnamese: "đẹp", vietnameseAlt: [], category: .adjectives),
            .init(german: "warm", germanAlt: ["warm"], vietnamese: "ấm", vietnameseAlt: [], category: .adjectives),
            .init(german: "kalt", germanAlt: ["kalt"], vietnamese: "lạnh", vietnameseAlt: [], category: .adjectives),
            .init(german: "heiß", germanAlt: ["heiß"], vietnamese: "nóng", vietnameseAlt: [], category: .adjectives),
            .init(german: "teuer", germanAlt: ["teuer"], vietnamese: "đắt", vietnameseAlt: [], category: .adjectives),
            .init(german: "billig", germanAlt: ["billig", "günstig"], vietnamese: "rẻ", vietnameseAlt: [], category: .adjectives),
            .init(german: "schnell", germanAlt: ["schnell"], vietnamese: "nhanh", vietnameseAlt: [], category: .adjectives),
            .init(german: "langsam", germanAlt: ["langsam"], vietnamese: "chậm", vietnameseAlt: [], category: .adjectives),
            .init(german: "einfach", germanAlt: ["einfach", "leicht"], vietnamese: "đơn giản", vietnameseAlt: ["dễ"], category: .adjectives),
            .init(german: "schwierig", germanAlt: ["schwierig", "kompliziert"], vietnamese: "khó", vietnameseAlt: ["phức tạp"], category: .adjectives),
        ],
        .questionWords: [
            .init(german: "wer", germanAlt: ["wer"], vietnamese: "ai", vietnameseAlt: [], category: .questionWords),
            .init(german: "was", germanAlt: ["was"], vietnamese: "gì", vietnameseAlt: [], category: .questionWords),
            .init(german: "wann", germanAlt: ["wann"], vietnamese: "khi nào", vietnameseAlt: [], category: .questionWords),
            .init(german: "wo", germanAlt: ["wo"], vietnamese: "ở đâu", vietnameseAlt: [], category: .questionWords),
            .init(german: "warum", germanAlt: ["warum"], vietnamese: "tại sao", vietnameseAlt: [], category: .questionWords),
            .init(german: "wie", germanAlt: ["wie"], vietnamese: "như thế nào", vietnameseAlt: [], category: .questionWords),
            .init(german: "welcher", germanAlt: ["welcher", "welche", "welches"], vietnamese: "cái nào", vietnameseAlt: [], category: .questionWords),
        ],
        .timeFrequency: [
            .init(german: "jetzt", germanAlt: ["jetzt"], vietnamese: "bây giờ", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "heute", germanAlt: ["heute"], vietnamese: "hôm nay", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "morgen", germanAlt: ["morgen"], vietnamese: "ngày mai", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "gestern", germanAlt: ["gestern"], vietnamese: "hôm qua", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "immer", germanAlt: ["immer"], vietnamese: "luôn luôn", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "oft", germanAlt: ["oft", "häufig", "normal"], vietnamese: "thường", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "manchmal", germanAlt: ["manchmal"], vietnamese: "thỉnh thoảng", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "selten", germanAlt: ["selten"], vietnamese: "hiếm khi", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "nie", germanAlt: ["nie"], vietnamese: "không bao giờ", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "bald", germanAlt: ["bald"], vietnamese: "sớm", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "schon", germanAlt: ["schon"], vietnamese: "đã", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "noch", germanAlt: ["noch"], vietnamese: "vẫn", vietnameseAlt: ["còn"], category: .timeFrequency),
            .init(german: "zuerst", germanAlt: ["zuerst"], vietnamese: "trước tiên", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "dann", germanAlt: ["dann"], vietnamese: "sau đó", vietnameseAlt: ["rồi"], category: .timeFrequency),
            .init(german: "später", germanAlt: ["später"], vietnamese: "sau này", vietnameseAlt: [], category: .timeFrequency),
            .init(german: "zuletzt", germanAlt: ["zuletzt"], vietnamese: "cuối cùng", vietnameseAlt: [], category: .timeFrequency),
        ],
        .prepositions: [
            .init(german: "in", germanAlt: ["in"], vietnamese: "trong", vietnameseAlt: [], category: .prepositions),
            .init(german: "an", germanAlt: ["an"], vietnamese: "tại", vietnameseAlt: [], category: .prepositions),
            .init(german: "auf", germanAlt: ["auf"], vietnamese: "trên", vietnameseAlt: ["lên"], category: .prepositions),
            .init(german: "unter", germanAlt: ["unter"], vietnamese: "dưới", vietnameseAlt: [], category: .prepositions),
            .init(german: "über", germanAlt: ["über"], vietnamese: "trên", vietnameseAlt: ["về"], category: .prepositions),
            .init(german: "mit", germanAlt: ["mit"], vietnamese: "với", vietnameseAlt: [], category: .prepositions),
            .init(german: "ohne", germanAlt: ["ohne"], vietnamese: "không có", vietnameseAlt: [], category: .prepositions),
            .init(german: "für", germanAlt: ["für"], vietnamese: "cho", vietnameseAlt: [], category: .prepositions),
            .init(german: "von", germanAlt: ["von"], vietnamese: "từ", vietnameseAlt: ["của"], category: .prepositions),
            .init(german: "zu", germanAlt: ["zu"], vietnamese: "đến", vietnameseAlt: [], category: .prepositions),
            .init(german: "nach", germanAlt: ["nach"], vietnamese: "tới", vietnameseAlt: ["sau"], category: .prepositions),
            .init(german: "bei", germanAlt: ["bei"], vietnamese: "tại", vietnameseAlt: ["gần"], category: .prepositions),
            .init(german: "aus", germanAlt: ["aus"], vietnamese: "từ", vietnameseAlt: ["ra khỏi"], category: .prepositions),
            .init(german: "seit", germanAlt: ["seit"], vietnamese: "từ khi", vietnameseAlt: [], category: .prepositions),
            .init(german: "bis", germanAlt: ["bis"], vietnamese: "đến khi", vietnameseAlt: [], category: .prepositions),
            .init(german: "zwischen", germanAlt: ["zwischen"], vietnamese: "giữa", vietnameseAlt: [], category: .prepositions),
            .init(german: "gegen", germanAlt: ["gegen"], vietnamese: "chống", vietnameseAlt: ["vào khoảng"], category: .prepositions),
        ],
        .connectors: [
            .init(german: "und", germanAlt: ["und"], vietnamese: "và", vietnameseAlt: [], category: .connectors),
            .init(german: "oder", germanAlt: ["oder"], vietnamese: "hoặc", vietnameseAlt: [], category: .connectors),
            .init(german: "aber", germanAlt: ["aber"], vietnamese: "nhưng", vietnameseAlt: [], category: .connectors),
            .init(german: "weil", germanAlt: ["weil"], vietnamese: "bởi vì", vietnameseAlt: [], category: .connectors),
            .init(german: "dass", germanAlt: ["dass"], vietnamese: "rằng", vietnameseAlt: [], category: .connectors),
            .init(german: "wenn", germanAlt: ["wenn"], vietnamese: "nếu", vietnameseAlt: ["khi"], category: .connectors),
            .init(german: "obwohl", germanAlt: ["obwohl"], vietnamese: "mặc dù", vietnameseAlt: [], category: .connectors),
            .init(german: "also", germanAlt: ["also"], vietnamese: "vậy", vietnameseAlt: ["do đó"], category: .connectors),
            .init(german: "dann", germanAlt: ["dann"], vietnamese: "rồi", vietnameseAlt: ["sau đó"], category: .connectors),
            .init(german: "deshalb", germanAlt: ["deshalb"], vietnamese: "vì vậy", vietnameseAlt: [], category: .connectors),
            .init(german: "trotzdem", germanAlt: ["trotzdem"], vietnamese: "mặc dù vậy", vietnameseAlt: [], category: .connectors),
        ],
        .adverbsFillers: [
            .init(german: "sehr", germanAlt: ["sehr"], vietnamese: "rất", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "auch", germanAlt: ["auch"], vietnamese: "cũng", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "nur", germanAlt: ["nur"], vietnamese: "chỉ", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "vielleicht", germanAlt: ["vielleicht"], vietnamese: "có thể", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "wirklich", germanAlt: ["wirklich"], vietnamese: "thật sự", vietnameseAlt: ["thực sự"], category: .adverbsFillers),
            .init(german: "gern", germanAlt: ["gern"], vietnamese: "thích", vietnameseAlt: ["một cách thích"], category: .adverbsFillers),
            .init(german: "lieber", germanAlt: ["lieber"], vietnamese: "thích hơn", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "genug", germanAlt: ["genug"], vietnamese: "đủ", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "fast", germanAlt: ["fast"], vietnamese: "gần như", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "ungefähr", germanAlt: ["ungefähr"], vietnamese: "khoảng", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "genau", germanAlt: ["genau"], vietnamese: "chính xác", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "gleich", germanAlt: ["gleich"], vietnamese: "ngay", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "zusammen", germanAlt: ["zusammen"], vietnamese: "cùng nhau", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "allein", germanAlt: ["allein"], vietnamese: "một mình", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "wieder", germanAlt: ["wieder"], vietnamese: "lại", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "weiter", germanAlt: ["weiter"], vietnamese: "tiếp tục", vietnameseAlt: [], category: .adverbsFillers),
            .init(german: "erst", germanAlt: ["erst"], vietnamese: "mới", vietnameseAlt: ["chỉ"], category: .adverbsFillers),
            .init(german: "natürlich", germanAlt: ["natürlich"], vietnamese: "tất nhiên", vietnameseAlt: [], category: .adverbsFillers),
        ],
        .interjectionsExpressions: [
            .init(german: "ja", germanAlt: ["ja"], vietnamese: "vâng", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "nein", germanAlt: ["nein"], vietnamese: "không", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "bitte", germanAlt: ["bitte"], vietnamese: "làm ơn", vietnameseAlt: ["xin mời", "không có gì"], category: .interjectionsExpressions),
            .init(german: "danke", germanAlt: ["danke"], vietnamese: "cảm ơn", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "hallo", germanAlt: ["hallo"], vietnamese: "xin chào", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "tschüss", germanAlt: ["tschüss"], vietnamese: "tạm biệt", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "guten Morgen", germanAlt: ["guten Morgen"], vietnamese: "chào buổi sáng", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "guten Abend", germanAlt: ["guten Abend"], vietnamese: "chào buổi tối", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "gute Nacht", germanAlt: ["gute Nacht"], vietnamese: "chúc ngủ ngon", vietnameseAlt: [], category: .interjectionsExpressions),
            .init(german: "Entschuldigung", germanAlt: ["Entschuldigung"], vietnamese: "xin lỗi", vietnameseAlt: ["thứ lỗi"], category: .interjectionsExpressions),
        ],
        .other: [
            // Keep empty or put misc words here.
        ]
    ]

    // MARK: - Public lists

    /// Flat list used everywhere else (counters, quiz, etc.)
    static var a1: [Word] {
        // Keep UI section order when flattening (nice-to-have)
        Category.ordered.flatMap { byCategory[$0] ?? [] }
    }

    /// Deduplicated list (by Vietnamese **and** German forms). Each surface form appears once.
    static var a1Unique: [Word] {
        mergeBySurfaceFormsKeepingFirst(a1)
    }

    /// Quick counts (handy for debugging UI counters)
    static var countOriginal: Int { a1.count }
    static var countUnique: Int { a1Unique.count }

    // MARK: - Merge logic

    /// Which side(s) to use as duplicate keys.
    private enum KeySide { case german, vietnamese }

    /// Merge words so that each **surface form** (VN or DE) appears only once.
    /// - Keeps the category and canonical forms of the first occurrence.
    /// - Merges all alt forms across duplicates.
    private static func mergeBySurfaceFormsKeepingFirst(
        _ words: [Word],
        keys: [KeySide] = [.vietnamese, .german]
    ) -> [Word] {
        // Map normalized key -> index of canonical word in `result`
        var indexByKey: [String: Int] = [:]
        var result: [Word] = []
        result.reserveCapacity(words.count)

        for word in words {
            let keySet = normalizedKeys(for: word, sides: keys)

            // Find if any key already exists
            var existingIndex: Int? = nil
            for key in keySet {
                if let idx = indexByKey[key] {
                    existingIndex = idx
                    break
                }
            }

            if let idx = existingIndex {
                // Merge into existing canonical entry
                let merged = merge(base: result[idx], with: word)
                result[idx] = merged

                // Update mapping with any newly-added keys
                let mergedKeys = normalizedKeys(for: merged, sides: keys)
                for k in mergedKeys { indexByKey[k] = idx }
            } else {
                // New canonical entry
                result.append(word)
                let idx = result.count - 1
                for k in keySet { indexByKey[k] = idx }
            }
        }

        return result
    }

    /// Merge two Word entries (same concept). Keeps:
    /// - Category & canonical DE/VN from the `base` (first occurrence).
    /// - Adds any new alternates from `other`.
    private static func merge(base: Word, with other: Word) -> Word {
        // German: keep base.german as canonical, merge alts and other's canonical
        let germanAll = orderedUnique(base.allGerman + other.allGerman)
        let canonicalGerman = base.german
        let germanAlt = germanAll.filter { $0 != canonicalGerman }

        // Vietnamese: keep base.vietnamese as canonical, merge alts and other's canonical
        let vnAll = orderedUnique(base.allVietnamese + other.allVietnamese)
        let canonicalVN = base.vietnamese
        let vnAlt = vnAll.filter { $0 != canonicalVN }

        return Word(
            german: canonicalGerman,
            germanAlt: germanAlt,
            vietnamese: canonicalVN,
            vietnameseAlt: vnAlt,
            category: base.category // keep first category for stability/ordering
        )
    }

    // MARK: - Helpers

    /// Build normalized key set for duplicate detection.
    private static func normalizedKeys(for w: Word, sides: [KeySide]) -> Set<String> {
        var keys = Set<String>()
        for side in sides {
            switch side {
            case .german:
                for s in w.allGerman { keys.insert(normalize(s)) }
            case .vietnamese:
                for s in w.allVietnamese { keys.insert(normalize(s)) }
            }
        }
        return keys
    }

    /// Normalize for duplicate detection: lowercase + trim + collapse inner spaces.
    /// (Keep diacritics — important for Vietnamese.)
    private static func normalize(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let collapsed = trimmed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return collapsed.lowercased()
    }

    /// Ordered uniqueness that preserves the first occurrence's original casing/spaces for display,
    /// while deduping using the same normalize() logic.
    private static func orderedUnique(_ arr: [String]) -> [String] {
        var seen: Set<String> = []
        var out: [String] = []
        out.reserveCapacity(arr.count)
        for s in arr {
            let key = normalize(s)
            if seen.insert(key).inserted {
                out.append(s)
            }
        }
        return out
    }
}
