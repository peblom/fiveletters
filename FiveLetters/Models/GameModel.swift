import Foundation

class GameModel {
    // MARK: - Properties
    
    // Game State
    private(set) var solution: String
    private(set) var attempts: [String] = []
    private(set) var evaluations: [WordEvaluation] = []
    private(set) var currentAttempt: String = ""
    private(set) var difficulty: Difficulty = .easy
    private(set) var letterEvaluations: [Character: LetterEvaluation] = [:]
    
    // Hints
    private(set) var possibleSolutions: [String] = []
    private(set) var oneLetterHint: (letter: Character, position: Int)?
    private(set) var bestNextGuess: String?
    
    // Computed Properties
    var isGameOver: Bool {
        return gameState != .playing
    }
    
    var gameState: GameState {
        if attempts.contains(solution) {
            return .won
        }
        if attempts.count >= 6 {
            return .lost
        }
        return .playing
    }
    
    // MARK: - Initialization
    
    init() {
        self.solution = WordList.solutions.randomElement() ?? "WORLD"
        updatePossibleSolutions()
    }
    
    // MARK: - Game Control
    
    func startNewGame() {
        solution = WordList.solutions.randomElement() ?? "WORLD"
        attempts = []
        evaluations = []
        currentAttempt = ""
        letterEvaluations = [:]
        oneLetterHint = nil
        bestNextGuess = nil
        updatePossibleSolutions()
    }
    
    func setDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
    }
    
    // MARK: - Attempt Handling
    
    func submitAttempt(_ attempt: String) -> AttemptValidation {
        // Grundlegende Validierung
        guard attempt.count == 5 else {
            return AttemptValidation(isValid: false, violationMessage: "Word must be 5 letters long")
        }
        
        guard WordList.accepted.contains(attempt) else {
            return AttemptValidation(isValid: false, violationMessage: "Not in word list")
        }
        
        // Schwierigkeitsgrad-spezifische Validierung
        if difficulty != .easy {
            // Prüfe auf Verwendung von als "nicht vorhanden" markierten Buchstaben
            for char in attempt {
                if letterEvaluations[char] == .absent {
                    return AttemptValidation(isValid: false, violationMessage: "Cannot use letter '\(char)' - marked as not in word")
                }
            }
        }
        
        if difficulty == .hard || difficulty == .expert {
            // Prüfe auf korrekte Verwendung von grünen und gelben Buchstaben
            if let validation = validateHardModeRules(attempt) {
                return validation
            }
        }
        
        // Versuch ist gültig - evaluiere und aktualisiere den Spielzustand
        let evaluation = evaluateAttempt(attempt)
        attempts.append(attempt)
        evaluations.append(evaluation)
        updateLetterEvaluations(attempt: attempt, evaluation: evaluation)
        currentAttempt = ""
        updatePossibleSolutions()
        
        return AttemptValidation(isValid: true)
    }
    
    // MARK: - Evaluation
    
    private func evaluateAttempt(_ attempt: String) -> WordEvaluation {
        var evaluations = Array(repeating: LetterEvaluation.absent, count: 5)
        var solutionChars = Array(solution)
        let attemptChars = Array(attempt)
        
        // Erste Runde: Finde exakte Übereinstimmungen (grün)
        for i in 0..<5 {
            if attemptChars[i] == solutionChars[i] {
                evaluations[i] = .correct
                solutionChars[i] = "#" // Markiere als verwendet
            }
        }
        
        // Zweite Runde: Finde falsch positionierte Buchstaben (gelb)
        for i in 0..<5 {
            if evaluations[i] == .absent {
                if let pos = solutionChars.firstIndex(of: attemptChars[i]) {
                    evaluations[i] = .present
                    solutionChars[pos] = "#" // Markiere als verwendet
                }
            }
        }
        
        return WordEvaluation(evaluations: evaluations)
    }
    
    private func updateLetterEvaluations(attempt: String, evaluation: WordEvaluation) {
        for (index, char) in attempt.enumerated() {
            let newEvaluation = evaluation.evaluations[index]
            
            // Aktualisiere nur, wenn die neue Bewertung "besser" ist
            if let existingEvaluation = letterEvaluations[char] {
                if existingEvaluation == .absent || 
                   (existingEvaluation == .present && newEvaluation == .correct) {
                    letterEvaluations[char] = newEvaluation
                }
            } else {
                letterEvaluations[char] = newEvaluation
            }
        }
    }
    
    // MARK: - Hard Mode Validation
    
    private func validateHardModeRules(_ attempt: String) -> AttemptValidation? {
        guard !evaluations.isEmpty else { return nil }
        
        let lastEvaluation = evaluations.last!
        let lastAttempt = attempts.last!
        
        // Prüfe grüne Buchstaben
        for i in 0..<5 {
            if lastEvaluation.evaluations[i] == .correct {
                if Array(attempt)[i] != Array(lastAttempt)[i] {
                    return AttemptValidation(
                        isValid: false,
                        violationMessage: "Must use '\(Array(lastAttempt)[i])' in position \(i + 1)"
                    )
                }
            }
        }
        
        // Prüfe gelbe Buchstaben
        for i in 0..<5 {
            if lastEvaluation.evaluations[i] == .present {
                let requiredChar = Array(lastAttempt)[i]
                
                // Für Expert Mode: Der Buchstabe darf nicht an der gleichen Position sein
                if difficulty == .expert && Array(attempt)[i] == requiredChar {
                    return AttemptValidation(
                        isValid: false,
                        violationMessage: "Letter '\(requiredChar)' must be used in a different position"
                    )
                }
                
                // Der Buchstabe muss verwendet werden
                if !attempt.contains(requiredChar) {
                    return AttemptValidation(
                        isValid: false,
                        violationMessage: "Must use the letter '\(requiredChar)'"
                    )
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Hints
    
    private func updatePossibleSolutions() {
        var solutions = WordList.solutions
        
        // Filtere basierend auf bisherigen Versuchen und Evaluationen
        for (attempt, evaluation) in zip(attempts, evaluations) {
            solutions = solutions.filter { solution in
                let testEvaluation = evaluateWord(attempt, against: solution)
                return testEvaluation == evaluation
            }
        }
        
        possibleSolutions = solutions
        updateBestNextGuess()
    }
    
    private func evaluateWord(_ attempt: String, against solution: String) -> WordEvaluation {
        var evaluations = Array(repeating: LetterEvaluation.absent, count: 5)
        var solutionChars = Array(solution)
        let attemptChars = Array(attempt)
        
        // Erste Runde: Finde exakte Übereinstimmungen
        for i in 0..<5 {
            if attemptChars[i] == solutionChars[i] {
                evaluations[i] = .correct
                solutionChars[i] = "#"
            }
        }
        
        // Zweite Runde: Finde falsch positionierte Buchstaben
        for i in 0..<5 {
            if evaluations[i] == .absent {
                if let pos = solutionChars.firstIndex(of: attemptChars[i]) {
                    evaluations[i] = .present
                    solutionChars[pos] = "#"
                }
            }
        }
        
        return WordEvaluation(evaluations: evaluations)
    }
    
    private func updateBestNextGuess() {
        guard !possibleSolutions.isEmpty else { return }
        
        if possibleSolutions.count == 1 {
            bestNextGuess = possibleSolutions[0]
        } else if possibleSolutions.count == 2 {
            bestNextGuess = "\(possibleSolutions[0]) or \(possibleSolutions[1])"
        } else {
            // Hier könnte eine komplexere Logik zur Bestimmung des besten nächsten Versuchs implementiert werden
            bestNextGuess = possibleSolutions.randomElement()
        }
    }
    
    func calculateOneLetterHint() {
        guard !isGameOver else { return }
        
        // Finde eine Position, die noch nicht korrekt ist
        var availablePositions: [Int] = []
        for i in 0..<5 {
            if evaluations.isEmpty || evaluations.last!.evaluations[i] != .correct {
                availablePositions.append(i)
            }
        }
        
        guard let position = availablePositions.randomElement() else { return }
        oneLetterHint = (letter: Array(solution)[position], position: position)
    }
    
    // MARK: - Letter Evaluations
    
    func getLetterEvaluation(for letter: Character) -> LetterEvaluation {
        return letterEvaluations[letter] ?? .empty
    }
}
