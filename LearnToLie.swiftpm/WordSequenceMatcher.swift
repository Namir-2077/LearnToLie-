import Foundation

// MARK: - Word Match Result

enum MatchType: Equatable {
    case correct(text: String)
    case incorrect(expected: String, actual: String)
    case missing(expected: String)
    case extra(actual: String)
}

struct WordMatchResult: Identifiable, Equatable {
    let id = UUID()
    let type: MatchType
    var text: String {
        switch type {
        case .correct(let text): return text
        case .incorrect(let expected, _): return expected
        case .missing(let expected): return expected
        case .extra(let actual): return actual
        }
    }
}

// MARK: - Word Sequence Matcher

struct WordSequenceMatcher {
    
    // Simple edit distance backtrace to find alignment between expected words and spoken words
    static func match(expected: String, actual: String) -> [WordMatchResult] {
        let expectedWords = tokenize(expected)
        let actualWords = tokenize(actual)
        
        let n = expectedWords.count
        let m = actualWords.count
        
        if n == 0 && m == 0 { return [] }
        if n == 0 { return actualWords.map { .init(type: .extra(actual: $0)) } }
        if m == 0 { return expectedWords.map { .init(type: .missing(expected: $0)) } }
        
        // DP matrix
        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        
        for i in 0...n { dp[i][0] = i }
        for j in 0...m { dp[0][j] = j }
        
        for i in 1...n {
            for j in 1...m {
                let cost = normalize(expectedWords[i-1]) == normalize(actualWords[j-1]) ? 0 : 1
                dp[i][j] = min(
                    dp[i-1][j] + 1,       // Deletion (missing word)
                    dp[i][j-1] + 1,       // Insertion (extra word)
                    dp[i-1][j-1] + cost   // Substitution
                )
            }
        }
        
        // Backtrace
        var results: [WordMatchResult] = []
        var i = n
        var j = m
        
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && normalize(expectedWords[i-1]) == normalize(actualWords[j-1]) {
                // Correct match
                results.append(WordMatchResult(type: .correct(text: expectedWords[i-1])))
                i -= 1
                j -= 1
            } else if i > 0 && j > 0 && dp[i][j] == dp[i-1][j-1] + 1 {
                // Substitution
                results.append(WordMatchResult(type: .incorrect(expected: expectedWords[i-1], actual: actualWords[j-1])))
                i -= 1
                j -= 1
            } else if i > 0 && (j == 0 || dp[i][j] == dp[i-1][j] + 1) {
                // Deletion (expected word was missing)
                results.append(WordMatchResult(type: .missing(expected: expectedWords[i-1])))
                i -= 1
            } else {
                // Insertion (extra spoken word)
                results.append(WordMatchResult(type: .extra(actual: actualWords[j-1])))
                j -= 1
            }
        }
        
        // Results are built backwards during backtrace
        return results.reversed()
    }
    
    // MARK: - Helpers
    
    private static func tokenize(_ text: String) -> [String] {
        return text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
    
    private static func normalize(_ word: String) -> String {
        return word.lowercased()
            .trimmingCharacters(in: .punctuationCharacters)
    }
}
