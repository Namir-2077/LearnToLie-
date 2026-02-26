import AVFoundation
import SwiftUI

@MainActor
final class VoiceDemonstrator: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking = false
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
        
        // Pre-warm the synthesizer to avoid delay on first playback
        let warmUp = AVSpeechUtterance(string: " ")
        warmUp.volume = 0
        synthesizer.speak(warmUp)
    }
    
    func speak(text: String, intensity: Double) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Map 1-10 intensity to speech parameters
        // Defaults: volume 1.0, pitchMultiplier 1.0, rate 0.5 (AVSpeechUtteranceDefaultSpeechRate)
        
        // Map volume: 1.0 -> 0.3 (quiet), 10.0 -> 1.0 (loud)
        utterance.volume = Float(0.3 + (intensity - 1.0) / 9.0 * 0.7)
        
        // Map pitch: 1.0 -> 0.9 (measured), 10.0 -> 1.15 (tense/high energy)
        utterance.pitchMultiplier = Float(0.9 + (intensity - 1.0) / 9.0 * 0.25)
        
        // Map rate: 1.0 -> 0.4 (slow), 10.0 -> 0.55 (fast)
        let defaultRate = AVSpeechUtteranceDefaultSpeechRate
        let minRate = defaultRate * 0.8
        let maxRate = defaultRate * 1.1
        utterance.rate = minRate + Float((intensity - 1.0) / 9.0) * (maxRate - minRate)
        
        // Use a good default voice if available
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        // Improve expression slightly
        utterance.preUtteranceDelay = 0.1
        
        synthesizer.speak(utterance)
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }
}
