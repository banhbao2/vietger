import Foundation

struct Word: Identifiable, Hashable, Codable {
    let german: String
    let germanAlt: [String]
    let vietnamese: String
    let vietnameseAlt: [String]
    let category: Category

    var id: String { "\(german)↔\(vietnamese)" }
    var allGerman: [String] { [german] + germanAlt }
    var allVietnamese: [String] { [vietnamese] + vietnameseAlt }
}
