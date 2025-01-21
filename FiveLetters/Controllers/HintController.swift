import Foundation
import SwiftUI

class HintController: ObservableObject {
    static let shared = HintController()
    
    @Published var bestGuess: String = ""
    @Published var isCalculating: Bool = false
    
    private var bestNextGuessWords: [String] = []
    private var allWords: [String] = []
    private var currentCalculationID: UUID?
    private var lastProcessedAttemptCount: Int = 0
    
    private struct LetterCount {
        var minCount: Int?
        var maxCount: Int
        
        init() {
            self.minCount = nil
            self.maxCount = 5
        }
        
        static func absent() -> LetterCount {
            var count = LetterCount()
            count.minCount = 0
            count.maxCount = 0
            return count
        }
        
        static func present(count: Int) -> LetterCount {
            var letterCount = LetterCount()
            letterCount.minCount = count
            return letterCount
        }
        
        static func exact(count: Int) -> LetterCount {
            var letterCount = LetterCount()
            letterCount.minCount = count
            letterCount.maxCount = count
            return letterCount
        }
    }
    
    func initializeWordList(from gameModel: GameModel) {
        print("📚 Initialisiere Wortliste vom GameModel")
        bestNextGuessWords = gameModel.acceptedWords
        allWords = gameModel.acceptedWords
        lastProcessedAttemptCount = 0
        print("📊 Anzahl Wörter: \(allWords.count)")
    }
    
    private init() {
        print("🎮 HintController wird initialisiert")
        
        // Registriere für Benachrichtigungen über komplette Versuche
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCompleteAttempt),
            name: Notification.Name("CompleteAttempt"),
            object: nil
        )
        print("📡 Registriert für CompleteAttempt Benachrichtigungen")
        
        // Registriere für Benachrichtigungen über Spielneustart
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewGame),
            name: Notification.Name("NewGame"),
            object: nil
        )
        print("📡 Registriert für NewGame Benachrichtigungen")
        
        // Registriere für Berechnungsanfragen
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCalculationRequest),
            name: Notification.Name("CalculateBestNextGuess"),
            object: nil
        )
        print("📡 Registriert für CalculateBestNextGuess Benachrichtigungen")
    }
    
    @objc private func handleNewGame(_ notification: Notification) {
        print("🎲 Neues Spiel erkannt")
        if let gameModel = notification.object as? GameModel {
            print("📚 Wortlisten vom GameModel erhalten")
            bestNextGuessWords = gameModel.acceptedWords
            allWords = gameModel.acceptedWords
            lastProcessedAttemptCount = 0
            print("📊 Anzahl Wörter: \(allWords.count)")
        }
    }
    
    private func filterAndCalculate(gameModel: GameModel) {
        // Prüfe ob dieser Versuch bereits verarbeitet wurde
        if gameModel.attempts.count == lastProcessedAttemptCount {
            print("⏭️ Dieser Versuch wurde bereits verarbeitet, überspringe")
            return
        }
        
        // Aktualisiere den Zähler für verarbeitete Versuche
        lastProcessedAttemptCount = gameModel.attempts.count
        
        // Erstelle eine neue Berechnungs-ID
        let calculationID = UUID()
        currentCalculationID = calculationID
        
        // Setze den Berechnungsstatus
        DispatchQueue.main.async {
            self.isCalculating = true
        }
        
        // Führe die Berechnung im Hintergrund aus
        DispatchQueue.global(qos: .userInitiated).async {
            // Prüfe ob diese Berechnung noch aktuell ist
            guard calculationID == self.currentCalculationID else {
                print("🚫 Berechnung wurde überholt, breche ab")
                return
            }
            
            // Filtere die Wortliste basierend auf den bisherigen Versuchen
            self.filterWordList(gameModel: gameModel)
            
            // Aktualisiere die UI im Hauptthread
            DispatchQueue.main.async {
                // Prüfe nochmals ob diese Berechnung noch aktuell ist
                guard calculationID == self.currentCalculationID else {
                    print("🚫 Berechnung wurde überholt, breche ab")
                    return
                }
                
                // Setze den besten nächsten Versuch
                if self.bestNextGuessWords.count == 1 {
                    self.bestGuess = self.bestNextGuessWords[0]
                } else if self.bestNextGuessWords.count == 2 {
                    self.bestGuess = "\(self.bestNextGuessWords[0]) or \(self.bestNextGuessWords[1])"
                } else if !self.bestNextGuessWords.isEmpty {
                    self.bestGuess = self.bestNextGuessWords[0]
                } else {
                    self.bestGuess = "Keine passenden Wörter gefunden"
                }
                
                // Beende den Berechnungsstatus
                self.isCalculating = false
            }
        }
    }
    
    @objc private func handleCompleteAttempt(_ notification: Notification) {
        if let gameModel = notification.object as? GameModel {
            filterAndCalculate(gameModel: gameModel)
        }
    }
    
    @objc private func handleCalculationRequest(_ notification: Notification) {
        if let gameModel = notification.object as? GameModel {
            filterAndCalculate(gameModel: gameModel)
        }
    }
    
    private func filterWordList(gameModel: GameModel) {
        // Erstelle ein Dictionary für die Buchstabenzählung
        var letterCounts: [Character: LetterCount] = [:]
        
        // Verarbeite jeden Versuch
        for (attempt, evaluation) in zip(gameModel.attempts, gameModel.evaluations) {
            let attemptArray = Array(attempt.uppercased())
            
            // Aktualisiere die Buchstabenzählung basierend auf der Evaluation
            for (index, (letter, eval)) in zip(attemptArray, evaluation.evaluations).enumerated() {
                switch eval {
                case .correct:
                    // Buchstabe ist an dieser Position korrekt
                    bestNextGuessWords = bestNextGuessWords.filter { word in
                        Array(word.uppercased())[index] == letter
                    }
                case .present:
                    // Buchstabe ist im Wort, aber an falscher Position
                    bestNextGuessWords = bestNextGuessWords.filter { word in
                        Array(word.uppercased())[index] != letter && // nicht an dieser Position
                        word.uppercased().contains(letter) // aber im Wort vorhanden
                    }
                    // Aktualisiere die minimale Anzahl für diesen Buchstaben
                    let currentCount = letterCounts[letter]?.minCount ?? 0
                    letterCounts[letter] = .present(count: currentCount + 1)
                case .absent:
                    // Wenn der Buchstabe nicht als .present oder .correct in diesem Versuch vorkommt
                    if !zip(attemptArray, evaluation.evaluations).contains(where: { 
                        $0.0 == letter && ($0.1 == .present || $0.1 == .correct)
                    }) {
                        letterCounts[letter] = .absent()
                    }
                case .empty:
                    break
                }
            }
        }
        
        // Filtere basierend auf den Buchstabenzählungen
        bestNextGuessWords = bestNextGuessWords.filter { word in
            let wordArray = Array(word.uppercased())
            return letterCounts.allSatisfy { letter, count in
                let letterCount = wordArray.filter { $0 == letter }.count
                if let minCount = count.minCount {
                    return letterCount >= minCount && letterCount <= count.maxCount
                }
                return letterCount <= count.maxCount
            }
        }
    }
}
