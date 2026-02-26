import Foundation

// MARK: - Performance Result

struct PerformanceResult: Sendable {
    let score: Double
    let summary: String
    let strengths: [String]
    let improvements: [String]
    let practicalTip: String
}

// MARK: - Performance Analyzer

enum PerformanceAnalyzer {
    
    // MARK: - Context Expectations
    
    private struct ContextExpectation {
        let amplitudeRange: ClosedRange<Float>
        let variationMin: Float
        let silenceMax: Float
    }
    
    private static func expectations(from characteristics: VocalCharacteristics) -> ContextExpectation {
        // Convert vocal characteristics into amplitude/variation/silence expectations
        let pitchLower = characteristics.pitchRange.lowercased()
        let paceLower = characteristics.pace.lowercased()
        let energyLower = characteristics.energy.lowercased()
        
        // Determine amplitude expectations based on energy level
        let amplitudeRange: ClosedRange<Float>
        if energyLower.contains("explosive") || energyLower.contains("high") || energyLower.contains("urgent") || energyLower.contains("power") {
            amplitudeRange = 0.35...1.0  // High energy
        } else if energyLower.contains("strong") || energyLower.contains("commanding") || energyLower.contains("engaged") {
            amplitudeRange = 0.25...0.75  // Strong/moderate-high energy
        } else if energyLower.contains("calm") || energyLower.contains("composed") || energyLower.contains("controlled") {
            amplitudeRange = 0.12...0.50  // Moderate/controlled energy
        } else if energyLower.contains("restrained") || energyLower.contains("measured") || energyLower.contains("subtle") || energyLower.contains("soothing") {
            amplitudeRange = 0.02...0.25  // Low/restrained energy
        } else {
            amplitudeRange = 0.12...0.50  // Default to moderate
        }
        
        // Determine variation expectations based on energy
        let variationMin: Float
        if energyLower.contains("explosive") || energyLower.contains("dynamic") || energyLower.contains("urgent") {
            variationMin = 0.10
        } else if energyLower.contains("strong") || energyLower.contains("engaged") {
            variationMin = 0.07
        } else if energyLower.contains("composed") || energyLower.contains("calm") || energyLower.contains("controlled") {
            variationMin = 0.04
        } else {
            variationMin = 0.01
        }
        
        // Determine silence expectations based on pace
        let silenceMax: Float
        if paceLower.contains("fast") || paceLower.contains("urgent") || paceLower.contains("building") {
            silenceMax = 0.25  // Less silence for faster paces
        } else if paceLower.contains("steady") || paceLower.contains("deliberate") || paceLower.contains("methodical") {
            silenceMax = 0.35
        } else if paceLower.contains("slower") || paceLower.contains("reassuring") || paceLower.contains("charging") {
            silenceMax = 0.40
        } else {
            silenceMax = 0.30  // Default
        }
        
        return ContextExpectation(
            amplitudeRange: amplitudeRange,
            variationMin: variationMin,
            silenceMax: silenceMax
        )
    }
    
    // MARK: - Analysis
    
    static func analyze(context: CharacterContext, metrics: PerformanceMetrics) -> PerformanceResult {
        let expected = expectations(from: context.deliveryGuidance.expectedCharacteristics)
        
        // 1. Amplitude alignment score (0–10)
        let amplitudeScore = scoreAmplitude(metrics.averageAmplitude, expected: expected)
        
        // 2. Dynamic variation score (0–10)
        let variationScore = scoreVariation(metrics.amplitudeVariation, expected: expected)
        
        // 3. Pacing score (0–10): penalize too much silence or none
        let pacingScore = scorePacing(metrics.silenceRatio, expected: expected)
        
        // 4. Consistency score: penalize long flat segments
        let consistencyScore = scoreConsistency(metrics.amplitudeHistory)
        
        // Weighted composite
        let raw = amplitudeScore * 0.35 + variationScore * 0.25 + pacingScore * 0.20 + consistencyScore * 0.20
        
        // Add a moderate buffer to motivate the user
        let baseBuffered = raw + 0.25
        
        // Clamp to 0-1 range, then map to 2.5-5.0 score range
        let clamped = min(1.0, max(0.0, baseBuffered))
        let finalScore = 2.5 + (clamped * 2.5)
        
        // Generate feedback
        let feedback = generateFeedback(
            context: context,
            score: finalScore,
            amplitudeScore: amplitudeScore,
            variationScore: variationScore,
            pacingScore: pacingScore,
            consistencyScore: consistencyScore,
            metrics: metrics
        )
        
        return feedback
    }
    
    // MARK: - Scoring Components
    
    private static func scoreAmplitude(_ avg: Float, expected: ContextExpectation) -> Double {
        let mid = (expected.amplitudeRange.lowerBound + expected.amplitudeRange.upperBound) / 2.0
        let range = expected.amplitudeRange.upperBound - expected.amplitudeRange.lowerBound
        
        if expected.amplitudeRange.contains(avg) {
            // In range: 1.0 at perfect center, 0.3 at edges
            let distance = abs(avg - mid) / (range / 2.0)
            return Double(1.0 - distance * 0.7)
        } else {
            // Out of range: severe penalty going negative
            let distance: Float
            if avg < expected.amplitudeRange.lowerBound {
                distance = expected.amplitudeRange.lowerBound - avg
            } else {
                distance = avg - expected.amplitudeRange.upperBound
            }
            return 0.3 - Double(distance) * 5.0
        }
    }
    
    private static func scoreVariation(_ variation: Float, expected: ContextExpectation) -> Double {
        let ratio = Double(variation / expected.variationMin)
        
        if ratio >= 1.0 {
            // Meets minimum: 1.0 at exactly minimum, up to 1.2 if exceeds
            return 0.8 + (ratio - 1.0) * 0.2
        } else {
            // Below minimum: penalize heavily
            return ratio - 1.0
        }
    }
    
    private static func scorePacing(_ silenceRatio: Float, expected: ContextExpectation) -> Double {
        let idealSilence: Float = expected.silenceMax * 0.5
        
        // Deviation from ideal silence ratio
        let deviation = abs(silenceRatio - idealSilence) / expected.silenceMax
        
        // 1.0 at ideal, goes down as deviation increases (quadratic penalty)
        return Double(1.0 - (deviation * deviation))
    }
    
    private static func scoreConsistency(_ history: [Float]) -> Double {
        guard history.count > 20 else { return 0.5 }
        
        // Check for long flat segments (>15 frames with < 0.01 variation)
        var flatCount = 0
        var maxFlat = 0
        for i in 1..<history.count {
            if abs(history[i] - history[i-1]) < 0.01 {
                flatCount += 1
                maxFlat = max(maxFlat, flatCount)
            } else {
                flatCount = 0
            }
        }
        
        let flatRatio = Double(maxFlat) / Double(history.count)
        // Penalize flat segments: 0% flat = 1.0, 100% flat = -0.3
        return 1.0 - (flatRatio * flatRatio)
    }
    
    // MARK: - Feedback Generation
    
    private static func generateFeedback(
        context: CharacterContext,
        score: Double,
        amplitudeScore: Double,
        variationScore: Double,
        pacingScore: Double,
        consistencyScore: Double,
        metrics: PerformanceMetrics
    ) -> PerformanceResult {
        var strengths: [String] = []
        var improvements: [String] = []
        
        // Identify strengths (scores above 0.4 — actual good performance)
        if amplitudeScore > 0.4 {
            strengths.append(amplitudeStrength(context: context))
        }
        if variationScore > 0.4 {
            strengths.append(variationStrength(context: context))
        }
        if pacingScore > 0.4 {
            strengths.append(pacingStrength(context: context))
        }
        if consistencyScore > 0.4 {
            strengths.append("Sustained engagement throughout the delivery.")
        }
        
        // Identify improvements (scores below 0.2 — areas needing work)
        if amplitudeScore < 0.2 {
            improvements.append(amplitudeImprovement(context: context, avg: metrics.averageAmplitude))
        }
        if variationScore < 0.2 {
            improvements.append(variationImprovement(context: context))
        }
        if pacingScore < 0.2 {
            improvements.append(pacingImprovement(context: context, silenceRatio: metrics.silenceRatio))
        }
        if consistencyScore < 0.2 {
            improvements.append("Avoid letting the energy drop mid-phrase.")
        }
        
        // Ensure at least one of each
        if strengths.isEmpty {
            strengths.append("You committed to the \(context.intent.lowercased()) performance.")
        }
        if improvements.isEmpty {
            improvements.append("Explore deeper contrast between phrases to emphasize your \(context.motivation.lowercased()).")
        }
        
        // Limit to 2 each
        strengths = Array(strengths.prefix(2))
        improvements = Array(improvements.prefix(2))
        
        let summary = generateSummary(score: score, context: context)
        let tip = generateTip(
            context: context,
            amplitudeScore: amplitudeScore,
            variationScore: variationScore,
            pacingScore: pacingScore
        )
        
        return PerformanceResult(
            score: score,
            summary: summary,
            strengths: strengths,
            improvements: improvements,
            practicalTip: tip
        )
    }
    
    // MARK: - Summaries
    
    private static func generateSummary(score: Double, context: CharacterContext) -> String {
        switch score {
        case 4.5...5.0:
            return "You captured the \(context.motivation.lowercased()) — a commanding performance."
        case 3.8..<4.5:
            return "Strong delivery of your \(context.intent.lowercased()). Push deeper into the stakes."
        case 2.8..<3.8:
            return "The \(context.motivation.lowercased()) is there — let it drive your voice."
        case 2.6..<2.8:
            return "You're finding the truth. Trust the impulse of your \(context.intent.lowercased())."
        default:
            return "You've laid a foundation. Explore the \(context.motivation.lowercased()) on the next take."
        }
    }
    
    // MARK: - Strength Phrases
    
    private static func amplitudeStrength(context: CharacterContext) -> String {
        let characteristicLower = context.deliveryGuidance.expectedCharacteristics.energy.lowercased()
        if characteristicLower.contains("power") || characteristicLower.contains("explosive") || characteristicLower.contains("high") {
            return "Strong vocal projection that commands the space."
        } else if characteristicLower.contains("urgent") || characteristicLower.contains("engaged") {
            return "Well-projected delivery that serves your intent."
        } else {
            return "Measured volume that draws the listener closer."
        }
    }
    
    private static func variationStrength(context: CharacterContext) -> String {
        let characteristicLower = context.deliveryGuidance.expectedCharacteristics.energy.lowercased()
        if characteristicLower.contains("dynamic") || characteristicLower.contains("urgent") {
            return "Dynamic shifts that reveal the emotional landscape of your \(context.intent.lowercased())."
        } else {
            return "Thoughtful tonal variation that reinforces your \(context.motivation.lowercased())."
        }
    }
    
    private static func pacingStrength(context: CharacterContext) -> String {
        let paceLower = context.deliveryGuidance.expectedCharacteristics.pace.lowercased()
        if paceLower.contains("fast") || paceLower.contains("urgent") {
            return "Forward momentum that drives the intention home."
        } else {
            return "Intentional pacing that lets each word land with impact."
        }
    }
    
    // MARK: - Improvement Phrases
    
    private static func amplitudeImprovement(context: CharacterContext, avg: Float) -> String {
        let expected = expectations(from: context.deliveryGuidance.expectedCharacteristics)
        let energyLower = context.deliveryGuidance.expectedCharacteristics.energy.lowercased()
        
        if avg < expected.amplitudeRange.lowerBound {
            if energyLower.contains("power") || energyLower.contains("explosive") {
                return "Push the emotional stakes — let your \(context.intent.lowercased()) fill the room."
            } else {
                return "Allow more vocal presence to support your \(context.motivation.lowercased())."
            }
        } else {
            if energyLower.contains("restrained") || energyLower.contains("subtle") {
                return "Pull back — find the power in restraint and control for your \(context.intent.lowercased())."
            } else {
                return "The projection overshot the \(context.motivation.lowercased()). Find the right ceiling."
            }
        }
    }
    
    private static func variationImprovement(context: CharacterContext) -> String {
        let energyLower = context.deliveryGuidance.expectedCharacteristics.energy.lowercased()
        if energyLower.contains("dynamic") || energyLower.contains("urgent") {
            return "Allow more dynamic rise and fall to reinforce your \(context.intent.lowercased())."
        } else {
            return "Introduce subtle tonal shifts to keep the \(context.motivation.lowercased()) alive."
        }
    }
    
    private static func pacingImprovement(context: CharacterContext, silenceRatio: Float) -> String {
        if silenceRatio > 0.4 {
            return "Your pacing hesitated — trust your \(context.motivation.lowercased()) and stay connected to the line."
        } else {
            return "Create more intentional pauses to build tension within your \(context.intent.lowercased())."
        }
    }
    
    // MARK: - Practical Tips
    
    private static func generateTip(
        context: CharacterContext,
        amplitudeScore: Double,
        variationScore: Double,
        pacingScore: Double
    ) -> String {
        // Find weakest area
        let scores = [
            ("amplitude", amplitudeScore),
            ("variation", variationScore),
            ("pacing", pacingScore)
        ]
        let weakest = scores.min(by: { $0.1 < $1.1 })?.0 ?? "variation"
        
        let energyLower = context.deliveryGuidance.expectedCharacteristics.energy.lowercased()
        
        switch weakest {
        case "amplitude":
            if energyLower.contains("power") || energyLower.contains("explosive") || energyLower.contains("urgent") {
                return "To support your \(context.motivation.lowercased()): take a deep breath and imagine projecting to fill a large space."
            } else {
                return "For your \(context.intent.lowercased()): try whispering first, then find the minimal volume needed to be heard."
            }
        case "variation":
            return "To emphasize your \(context.motivation.lowercased()): pause half a second before a key word, then shift your tone as you land it."
        case "pacing":
            if energyLower.contains("urgent") || energyLower.contains("explosive") {
                return "Ground yourself with one breath cycle before starting. Let the \(context.motivation.lowercased()) launch the first word."
            } else {
                return "Read the line silently first, marking where your \(context.intent.lowercased()) naturally builds. Honor those beats."
            }
        default:
            return "Record twice — once as you just did, once pushing further into your \(context.motivation.lowercased()). Compare the difference."
        }
    }
}
