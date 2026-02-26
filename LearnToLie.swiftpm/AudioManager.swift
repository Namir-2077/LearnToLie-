import AVFoundation
import SwiftUI
import Accelerate

// MARK: - Recorded Performance Metrics

struct PerformanceMetrics: Sendable {
    let averageAmplitude: Float
    let peakAmplitude: Float
    let amplitudeVariation: Float
    let duration: TimeInterval
    let silenceRatio: Float
    let amplitudeHistory: [Float]
}

// MARK: - Audio Manager

@MainActor
final class AudioManager: ObservableObject {
    @Published var isRecording = false
    @Published var currentAmplitude: Float = 0.0
    @Published var waveformSamples: [Float] = Array(repeating: 0, count: 80)
    @Published var permissionGranted = false
    @Published var recordingDuration: TimeInterval = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var amplitudeHistory: [Float] = []
    private var silenceFrameCount: Int = 0
    private var totalFrameCount: Int = 0
    private var peakAmplitude: Float = 0.0
    private var recordingStartTime: Date?
    private var durationTask: Task<Void, Never>?
    
    static let maxRecordingDuration: TimeInterval = 20.0
    
    nonisolated init() {}
    
    // MARK: - Permission
    
    func requestPermission() {
        Task {
            let granted = await AVAudioApplication.requestRecordPermission()
            self.permissionGranted = granted
        }
    }
    
    // MARK: - Recording
    
    func startRecording() {
        guard permissionGranted else {
            requestPermission()
            return
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
            return
        }
        
        // Reset metrics
        amplitudeHistory.removeAll()
        silenceFrameCount = 0
        totalFrameCount = 0
        peakAmplitude = 0.0
        recordingDuration = 0.0
        waveformSamples = Array(repeating: 0, count: 80)
        
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        configureTap(on: engine)
        
        do {
            try engine.start()
            isRecording = true
            recordingStartTime = Date()
            
            // Duration tracking via structured Task (no Timer)
            durationTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(100))
                    guard let self else { return }
                    guard let start = self.recordingStartTime else { return }
                    self.recordingDuration = Date().timeIntervalSince(start)
                    
                    if self.recordingDuration >= AudioManager.maxRecordingDuration {
                        self.stopRecording()
                        return
                    }
                }
            }
        } catch {
            print("Engine start error: \(error)")
        }
    }
    
    func stopRecording() {
        durationTask?.cancel()
        durationTask = nil
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Metrics
    
    func captureMetrics() -> PerformanceMetrics {
        let avg = amplitudeHistory.isEmpty ? 0 : amplitudeHistory.reduce(0, +) / Float(amplitudeHistory.count)
        
        let mean = avg
        let squareDiffs = amplitudeHistory.map { ($0 - mean) * ($0 - mean) }
        let variation = squareDiffs.isEmpty ? 0 : sqrtf(squareDiffs.reduce(0, +) / Float(squareDiffs.count))
        
        let silenceRatio = totalFrameCount > 0 ? Float(silenceFrameCount) / Float(totalFrameCount) : 0
        
        return PerformanceMetrics(
            averageAmplitude: avg,
            peakAmplitude: peakAmplitude,
            amplitudeVariation: variation,
            duration: recordingDuration,
            silenceRatio: silenceRatio,
            amplitudeHistory: amplitudeHistory
        )
    }
    
    // MARK: - Private
    
    nonisolated private func configureTap(on engine: AVAudioEngine) {
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = Int(buffer.frameLength)
            
            var rms: Float = 0
            vDSP_measqv(channelData, 1, &rms, vDSP_Length(frameLength))
            rms = sqrtf(rms)
            let amplitude = min(rms * 8.0, 1.0)
            
            Task { @MainActor [weak self] in
                self?.processAmplitude(amplitude)
            }
        }
    }
    
    private func processAmplitude(_ amplitude: Float) {
        currentAmplitude = amplitude
        
        waveformSamples.removeFirst()
        waveformSamples.append(amplitude)
        
        amplitudeHistory.append(amplitude)
        totalFrameCount += 1
        
        if amplitude > peakAmplitude {
            peakAmplitude = amplitude
        }
        
        if amplitude < 0.05 {
            silenceFrameCount += 1
        }
    }
}
