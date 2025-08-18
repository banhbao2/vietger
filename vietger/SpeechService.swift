import Foundation
import AVFoundation

enum SpeechLanguage {
    case german
    case vietnamese

    var bcp47: String {
        switch self {
        case .german: return "de-DE"
        case .vietnamese: return "vi-VN"
        }
    }

    var fallbackBCP47: String {
        switch self {
        case .german: return "de-DE"
        case .vietnamese: return "vi-VN"
        }
    }

    var label: String {
        switch self {
        case .german: return "DE"
        case .vietnamese: return "VI"
        }
    }
}

protocol SpeechService {
    func speak(_ text: String, lang: SpeechLanguage, rate: Float)
}

final class DefaultSpeechService: SpeechService {
    private let synth = AVSpeechSynthesizer()

    func speak(_ text: String, lang: SpeechLanguage, rate: Float) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Pick the best available voice for the requested language
        let preferredCode = lang.bcp47
        let voice = AVSpeechSynthesisVoice(language: preferredCode)
            ?? AVSpeechSynthesisVoice(language: lang.fallbackBCP47)
            ?? AVSpeechSynthesisVoice(language: "en-US")

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        synth.speak(utterance)
    }
}
