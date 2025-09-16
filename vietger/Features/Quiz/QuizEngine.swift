import Foundation

final class QuizEngine {
    func expectedAnswers(for word: Word, direction: QuizDirection) -> [String] {
        direction.isGermanToVietnamese ? word.allVietnamese : word.allGerman
    }
    
    func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .lowercased()
    }
    
    func isCorrect(input: String, word: Word, direction: QuizDirection) -> Bool {
        let normalizedInput = normalize(input)
        let expectedAnswers = expectedAnswers(for: word, direction: direction)
            .map(normalize)
        return expectedAnswers.contains(normalizedInput)
    }
}
