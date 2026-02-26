import Foundation

// MARK: - Character Context

struct CharacterContext: Sendable, Equatable {
    let originContext: String
    let destinationContext: String
    let intent: String
    let motivation: String
    
    var deliveryGuidance: DeliveryGuidance {
        generateGuidance()
    }
    
    private func generateGuidance() -> DeliveryGuidance {
        let intentLower = intent.lowercased()
        let motivationLower = motivation.lowercased()
        
        // Template-based guidance matrix
        if intentLower.contains("threaten") || intentLower.contains("intimidate") {
            if motivationLower.contains("desper") {
                return DeliveryGuidance(
                    tips: [
                        "Lower your pitch slightly to convey controlled danger",
                        "Use direct, punchy delivery with minimal filler words",
                        "Emphasize key words with intentional pauses before/after",
                        "Maintain steady tempo even when emotional",
                        "End phrases with downward inflection for authority"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Low to mid",
                        pace: "Deliberate and controlled",
                        emphasis: "High on key words",
                        breathPauses: "Strategic pauses for impact",
                        energy: "Restrained intensity"
                    )
                )
            } else if motivationLower.contains("power") || motivationLower.contains("control") {
                return DeliveryGuidance(
                    tips: [
                        "Project confidence through steady volume and pace",
                        "Use longer phrases to show command of the situation",
                        "Vary tone only for calculated effect",
                        "Place emphasis on verbs and action words",
                        "Maintain forward momentum without rushing"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Mid to low",
                        pace: "Steady and commanding",
                        emphasis: "On action words",
                        breathPauses: "Minimal, confident",
                        energy: "Controlled power"
                    )
                )
            } else {
                return DeliveryGuidance(
                    tips: [
                        "Use lower pitch to suggest danger",
                        "Speak with clear enunciation and controlled volume",
                        "Pause briefly before delivering the threat",
                        "Avoid sounding angry—sound determined instead",
                        "End on a strong note to reinforce the message"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Lower than normal",
                        pace: "Controlled",
                        emphasis: "Deliberate",
                        breathPauses: "Strategic",
                        energy: "Contained"
                    )
                )
            }
        } else if intentLower.contains("persuade") || intentLower.contains("convince") {
            if motivationLower.contains("desper") {
                return DeliveryGuidance(
                    tips: [
                        "Let some emotional urgency show in your voice",
                        "Use conversational, direct language patterns",
                        "Place emphasis on reasons and benefits",
                        "Vary pitch to keep the listener engaged",
                        "Create space for the listener to feel heard"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Varied, conversational",
                        pace: "Engaged, slightly faster",
                        emphasis: "On compelling reasons",
                        breathPauses: "Natural, breathing points",
                        energy: "Urgent but controlled"
                    )
                )
            } else if motivationLower.contains("logical") || motivationLower.contains("reason") {
                return DeliveryGuidance(
                    tips: [
                        "Speak clearly and methodically—like presenting facts",
                        "Use even pacing to suggest confidence in your argument",
                        "Emphasize logical connectors: 'therefore,' 'because'",
                        "Avoid emotional variation; let your words do the work",
                        "Build from point to point with slight crescendo"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Even, rational",
                        pace: "Methodical",
                        emphasis: "On logical points",
                        breathPauses: "Between ideas",
                        energy: "Calm, reasoned"
                    )
                )
            } else {
                return DeliveryGuidance(
                    tips: [
                        "Speak with genuine interest in the listener's perspective",
                        "Use warm, inviting tone throughout",
                        "Vary your pitch to show enthusiasm",
                        "Place emphasis on shared benefits",
                        "End on an upward note to invite agreement"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Warm, varied",
                        pace: "Natural, conversational",
                        emphasis: "On benefits",
                        breathPauses: "Natural",
                        energy: "Engaging"
                    )
                )
            }
        } else if intentLower.contains("seduce") || intentLower.contains("charm") || intentLower.contains("attract") {
            return DeliveryGuidance(
                tips: [
                    "Use a lower, slower pitch than your natural speaking voice",
                    "Add subtle breathiness to your delivery",
                    "Emphasize words that create intimacy or connection",
                    "Use longer pauses to create tension and anticipation",
                    "Let your voice suggest confidence and ease"
                ],
                expectedCharacteristics: VocalCharacteristics(
                    pitchRange: "Lower, sultry",
                    pace: "Slower, deliberate",
                    emphasis: "On intimate words",
                    breathPauses: "Longer, charged pauses",
                    energy: "Suggestive, confident"
                )
            )
        } else if intentLower.contains("plead") || intentLower.contains("beg") || intentLower.contains("desperate") {
            return DeliveryGuidance(
                tips: [
                    "Allow your voice to show vulnerability and emotion",
                    "Use higher pitch than normal to convey pleading",
                    "Vary volume to emphasize desperation",
                    "Use shorter, building phrases for escalation",
                    "Let your breath show—don't hide the strain"
                ],
                expectedCharacteristics: VocalCharacteristics(
                    pitchRange: "Higher, strained",
                    pace: "Urgent, building",
                    emphasis: "On emotional words",
                    breathPauses: "Ragged, emotional",
                    energy: "Desperate, vulnerable"
                )
            )
        } else if intentLower.contains("deceive") || intentLower.contains("lie") {
            if motivationLower.contains("self-protect") || motivationLower.contains("survival") {
                return DeliveryGuidance(
                    tips: [
                        "Deliver with apparent confidence—not hesitation",
                        "Keep volume and pace steady to seem believable",
                        "Avoid over-explaining; let the lie sit simply",
                        "Place emphasis on believable details",
                        "End strong, as if there's nothing more to say"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Normal, convinced-sounding",
                        pace: "Steady, not defensive",
                        emphasis: "On credible details",
                        breathPauses: "Natural, assured",
                        energy: "Calm conviction"
                    )
                )
            } else {
                return DeliveryGuidance(
                    tips: [
                        "Keep the lie simple and delivered matter-of-factly",
                        "Use the same vocal patterns as truth-telling",
                        "Avoid defensive over-explanation",
                        "Maintain eye contact energy (imagine it)",
                        "End decisively without trailing off"
                    ],
                    expectedCharacteristics: VocalCharacteristics(
                        pitchRange: "Neutral, believable",
                        pace: "Confident",
                        emphasis: "Minimal, natural",
                        breathPauses: "Normal",
                        energy: "Composed"
                    )
                )
            }
        } else if intentLower.contains("comfort") || intentLower.contains("console") {
            return DeliveryGuidance(
                tips: [
                    "Use a warm, gentle tone throughout",
                    "Speak slightly slower than normal for reassurance",
                    "Lower your pitch slightly to suggest safety",
                    "Emphasize words of support and understanding",
                    "Use longer, sustained phrases to convey calm"
                ],
                expectedCharacteristics: VocalCharacteristics(
                    pitchRange: "Warm, slightly lowered",
                    pace: "Slower, reassuring",
                    emphasis: "On comforting words",
                    breathPauses: "Gentle, present",
                    energy: "Soothing, supportive"
                )
            )
        } else {
            // Default guidance for unmatched combinations
            return DeliveryGuidance(
                tips: [
                    "Speak clearly and naturally",
                    "Maintain consistent energy throughout",
                    "Let your character's emotional state guide your delivery",
                    "Use pauses to emphasize important moments",
                    "Trust your instincts and commit fully to the intention"
                ],
                expectedCharacteristics: VocalCharacteristics(
                    pitchRange: "Natural",
                    pace: "Conversational",
                    emphasis: "On key words",
                    breathPauses: "Natural",
                    energy: "Committed"
                )
            )
        }
    }
}

// MARK: - Delivery Guidance

struct DeliveryGuidance: Sendable, Equatable {
    let tips: [String]
    let expectedCharacteristics: VocalCharacteristics
}

struct VocalCharacteristics: Sendable, Equatable {
    let pitchRange: String
    let pace: String
    let emphasis: String
    let breathPauses: String
    let energy: String
}

// MARK: - Presets

struct ContextPreset: Sendable, Equatable, Identifiable {
    let id: UUID = UUID()
    let label: String
    let originContext: String
    let destinationContext: String
    let intent: String
    let motivation: String
}

enum ContextPresets {
    static let origins: [String] = [
        "Confrontation",
        "Deception",
        "Plea",
        "Revelation",
        "Accusation",
        "Offering",
        "Demand",
        "Confession",
        "Seduction",
        "Negotiation",
        "Custom"
    ]
    
    static let destinations: [String] = [
        "Reconciliation",
        "Escape",
        "Manipulation",
        "Understanding",
        "Justice",
        "Gain/Acquisition",
        "Submission",
        "Forgiveness",
        "Connection",
        "Agreement",
        "Custom"
    ]
    
    static let intents: [String] = [
        "Threaten",
        "Persuade",
        "Seduce",
        "Plead",
        "Deceive",
        "Comfort",
        "Accuse",
        "Confess",
        "Demand",
        "Manipulate",
        "Custom"
    ]
    
    static let motivations: [String] = [
        "Desperation",
        "Power/Control",
        "Logical Reason",
        "Self-Protection",
        "Love/Connection",
        "Revenge",
        "Survival",
        "Ambition",
        "Redemption",
        "Fear",
        "Custom"
    ]
    
    static let commonScenarios: [ContextPreset] = [
        ContextPreset(
            label: "Threatening villian",
            originContext: "Confrontation",
            destinationContext: "Submission",
            intent: "Threaten",
            motivation: "Power/Control"
        ),
        ContextPreset(
            label: "Desperate plea",
            originContext: "Plea",
            destinationContext: "Reconciliation",
            intent: "Plead",
            motivation: "Desperation"
        ),
        ContextPreset(
            label: "Seductive charm",
            originContext: "Seduction",
            destinationContext: "Connection",
            intent: "Seduce",
            motivation: "Love/Connection"
        ),
        ContextPreset(
            label: "Logical persuasion",
            originContext: "Negotiation",
            destinationContext: "Agreement",
            intent: "Persuade",
            motivation: "Logical Reason"
        ),
        ContextPreset(
            label: "Guilty confession",
            originContext: "Confession",
            destinationContext: "Forgiveness",
            intent: "Confess",
            motivation: "Redemption"
        ),
    ]
}
