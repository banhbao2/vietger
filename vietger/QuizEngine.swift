import Foundation

struct QuizEngine {
    func expectedAnswers(for word: Word, direction: QuizDirection) -> [String] {
        direction == .deToVi ? word.allVietnamese : word.allGerman
    }

    func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
         .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
         .lowercased()
    }

    /// Strict match; you can later plug in fuzzy (Levenshtein) here.
    func isCorrect(input: String, word: Word, direction: QuizDirection) -> Bool {
        let answers = expectedAnswers(for: word, direction: direction).map(normalize)
        return answers.contains(normalize(input))
    }
}
