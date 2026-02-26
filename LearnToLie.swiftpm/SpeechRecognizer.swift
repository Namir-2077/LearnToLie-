import SwiftUI
import AVFoundation
import Speech

@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var transcript: String = ""
    @Published var isAuthorized: Bool = false
    @Published var errorMsg: String?
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Defaulting to English but can be configured
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    init() {
        requestAuthorization()
    }
    
    nonisolated private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            Task { @MainActor in
                self.isAuthorized = status == .authorized
                if status != .authorized {
                    self.errorMsg = "Speech recognition permission denied."
                }
            }
        }
    }
    
    func startRecording() {
        guard isAuthorized, let recognizer = speechRecognizer, recognizer.isAvailable else {
            errorMsg = "Recognizer not available."
            return
        }
        
        do {
            // Cancel previous tasks
            recognitionTask?.cancel()
            self.recognitionTask = nil
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let request = recognitionRequest else {
                errorMsg = "Unable to create request."
                return
            }
            request.shouldReportPartialResults = true
            
            configureTap(on: audioEngine, request: request)
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            transcript = ""
            errorMsg = nil
            
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    
                    var isFinal = false
                    
                    if let result = result {
                        self.transcript = result.bestTranscription.formattedString
                        isFinal = result.isFinal
                    }
                    
                    if error != nil || isFinal {
                        self.stopRecording()
                    }
                }
            }
            
        } catch {
            errorMsg = "Audio Engine Failed: \(error.localizedDescription)"
            stopRecording()
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
    
    // MARK: - Private
    
    nonisolated private func configureTap(on engine: AVAudioEngine, request: SFSpeechAudioBufferRecognitionRequest) {
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
    }
}
