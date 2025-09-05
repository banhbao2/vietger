import Foundation

struct QuizEngine {
    func expectedAnswers(for word: Word, direction: QuizDirection) -> [String] {
        direction.isGermanToVietnamese ? word.allVietnamese : word.allGerman
    }

    func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines)
         .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
         .lowercased()
    }

    func isCorrect(input: String, word: Word, direction: QuizDirection) -> Bool {
        let answers = expectedAnswers(for: word, direction: direction).map(normalize)
        return answers.contains(normalize(input))
    }
}
