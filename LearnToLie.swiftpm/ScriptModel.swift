import SwiftUI

// MARK: - Emotion Enum

enum Emotion: String, Codable, CaseIterable, Sendable {
    case calm = "Calm"
    case angry = "Angry"
    case fearful = "Fearful"
    case conflicted = "Conflicted"
    case loving = "Loving"
}

// MARK: - Beat Model

struct Beat: Identifiable, Codable, Sendable {
    let id: UUID
    var text: String
    var emotion: Emotion?
    var hasPause: Bool
    var intensity: Double
    
    init(id: UUID = UUID(), text: String, emotion: Emotion? = nil, hasPause: Bool = false, intensity: Double = 5.0) {
        self.id = id
        self.text = text
        self.emotion = emotion
        self.hasPause = hasPause
        self.intensity = intensity
    }
}

// MARK: - Script Model

struct Script: Codable, Sendable {
    var rawText: String
    var beats: [Beat]
    var createdAt: Date
    
    init(rawText: String, beats: [Beat] = [], createdAt: Date = Date()) {
        self.rawText = rawText
        self.beats = beats
        self.createdAt = createdAt
    }
}

// MARK: - Script Store

@MainActor
final class ScriptStore: ObservableObject {
    @Published var currentScript: Script?
    @Published var hasCompletedOnboarding: Bool = false
    
    private let fileName = "learntolie_script.json"
    
    init() {
        loadScript()
    }
    
    // MARK: - Beat Parsing
    
    func parseBeats(from text: String) -> [Beat] {
        // Split on sentence-ending punctuation and line breaks
        let separators = CharacterSet(charactersIn: ".?!\n")
        let components = text.unicodeScalars.split { separators.contains($0) }
        
        var beats: [Beat] = []
        for component in components {
            let sentence = String(component).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                beats.append(Beat(text: sentence))
            }
        }
        return beats
    }
    
    func saveAndParseScript(_ text: String) {
        let beats = parseBeats(from: text)
        let script = Script(rawText: text, beats: beats)
        currentScript = script
        saveScript()
    }
    
    func updateBeat(_ beat: Beat) {
        guard var script = currentScript,
              let index = script.beats.firstIndex(where: { $0.id == beat.id }) else { return }
        script.beats[index] = beat
        currentScript = script
        saveScript()
    }
    
    // MARK: - Persistence
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }
    
    func saveScript() {
        guard let script = currentScript else { return }
        do {
            let data = try JSONEncoder().encode(script)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func loadScript() {
        do {
            let data = try Data(contentsOf: fileURL)
            currentScript = try JSONDecoder().decode(Script.self, from: data)
        } catch {
            currentScript = nil
        }
    }
    
    // MARK: - Sample Scripts
    
    enum SampleScript: String, CaseIterable {
        case hamlet = "Hamlet"
        case frankenstein = "Frankenstein"
        case scentOfAWoman = "Scent Of A Woman"
        case devilsAdvocate = "The Devil's Advocate"
        case othello = "Othello"
        
        var text: String {
            switch self {
            case .hamlet:
                return """
                To be, or not to be, that is the question.
                Whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune.
                Or to take arms against a sea of troubles, and by opposing end them.
                To die — to sleep, no more.
                And by a sleep to say we end the heart-ache and the thousand natural shocks that flesh is heir to.
                'Tis a consummation devoutly to be wish'd.
                To die, to sleep.
                To sleep, perchance to dream — ay, there's the rub.
                For in that sleep of death what dreams may come, when we have shuffled off this mortal coil, must give us pause.
                There's the respect that makes calamity of so long life.
                """
            case .frankenstein:
                return """
                I collected the instruments of life around me, that I might infuse a spark of being into the lifeless thing that lay at my feet.
                It was already one in the morning; the rain pattered dismally against the panes, and my candle was nearly burnt out.
                How can I describe my emotions at this catastrophe, or how delineate the wretch whom with such infinite pains and care I had endeavoured to form?
                His limbs were in proportion, and I had selected his features as beautiful.
                Beautiful! Great God!
                His yellow skin scarcely covered the work of muscles and arteries beneath.
                """
            case .scentOfAWoman:
                return """
                I don't know if Charlie's silence here today is right or wrong.
                I'm not a judge or jury.
                But I can tell you this: he won't sell anybody out to buy his future!!
                And that, my friends, is called integrity. That's called courage.
                Now that's the stuff leaders should be made of.
                I have come to the crossroads in my life.
                I always knew what the right path was. Without exception, I knew.
                But I never took it.
                You know why? It was too damn hard.
                """
            case .devilsAdvocate:
                return """
                Let me give you a little inside information about God.
                God likes to watch. He's a prankster.
                Think about it. He gives man instincts.
                He gives you this extraordinary gift, and then what does He do?
                I swear, for His own amusement, his own private, cosmic gag reel, He sets the rules in opposition.
                It's the goof of all time. You look, but don't touch. Touch, but don't taste. Taste, but don't swallow.
                And while you're jumping from one foot to the next, what is He doing?
                He's laughing his sick, fucking ass off!
                He's a tight-ass! He's a sadist!
                """
            case .othello:
                return """
                It is the cause, it is the cause, my soul,—
                Let me not name it to you, you chaste stars!—
                It is the cause. Yet I'll not shed her blood;
                Nor scar that whiter skin of hers than snow,
                And smooth as monumental alabaster.
                Yet she must die, else she'll betray more men.
                Put out the light, and then put out the light.
                """
            }
        }
    }
}
