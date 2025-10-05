import Foundation
import AVFoundation

protocol SpeechService {
    func speak(_ text: String, lang: SpeechLanguage, rate: Float)
}

final class DefaultSpeechService: SpeechService {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, lang: SpeechLanguage, rate: Float) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        let voice = findBestVoice(for: lang)
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.voice = voice
        utterance.rate = rate
        
        synthesizer.speak(utterance)
    }
    
    private func findBestVoice(for language: SpeechLanguage) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice(language: language.bcp47)
        ?? AVSpeechSynthesisVoice(language: language.fallbackBCP47)
        ?? AVSpeechSynthesisVoice(language: "en-US")
    }
}
