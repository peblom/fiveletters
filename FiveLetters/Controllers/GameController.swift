import Foundation
import SwiftUI

class GameController: ObservableObject {
    static let shared = GameController()
    
    // Model
    @Published private(set) var gameModel = GameModel()
    
    // UI State
    @Published var showTutorial = false
    @Published var selectedTutorialType: TutorialType = .rules
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showHint = false
    @Published var hintMessage = ""
    
    // Hint State
    @Published var showTakeAPeekAlert = false
    @Published var showOneLetterAlert = false
    @Published var showBestNextGuessAlert = false
    
    // Tutorial State
    @Published var tutorialTitle = ""
    @Published var tutorialFileName = ""
    
    private var hintUsedThisAttempt = false
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Game Control
    
    func startNewGame() {
        gameModel = GameModel()
        hintUsedThisAttempt = false
        NotificationCenter.default.post(name: .newGameStarted, object: nil)
    }
    
    // MARK: - Input Handling
    
    func addLetter(_ letter: String) {
        guard !gameModel.isGameOver else { return }
        guard gameModel.currentAttempt.count < 5 else { return }
        gameModel.addLetter(letter)
    }
    
    func removeLetter() {
        guard !gameModel.isGameOver else { return }
        guard !gameModel.currentAttempt.isEmpty else { return }
        gameModel.removeLetter()
    }
    
    func submitAttempt() {
        guard !gameModel.isGameOver else { return }
        guard gameModel.currentAttempt.count == 5 else { return }
        
        let result = gameModel.submitAttempt()
        if result.violations.isEmpty {
            hintUsedThisAttempt = false  // Reset nach jedem erfolgreichen Versuch
            if gameModel.isGameOver {
                if gameModel.hasWon {
                    showAlert(title: "Gewonnen!", message: "Gratulation! Sie haben das Wort in \(gameModel.attempts.count) Versuchen erraten.")
                } else {
                    showAlert(title: "Verloren!", message: "Das gesuchte Wort war: \(gameModel.solution)")
                }
            }
        } else {
            showAlert(title: "Ungültiger Versuch", message: result.violations.joined(separator: "\n"))
        }
    }
    
    func setDifficulty(_ difficulty: Difficulty) {
        gameModel.setDifficulty(difficulty)
        startNewGame()
    }
    
    // MARK: - Hint Control
    
    var canUseTakeAPeek: Bool {
        return gameModel.gameState == .playing && !hintUsedThisAttempt
    }
    
    var canUseOneLetterHint: Bool {
        guard !gameModel.hintLetterUsed && gameModel.gameState != .gameOver else {
            return false
        }
        
        let currentAttempt = gameModel.attempts.count
        switch gameModel.difficulty {
        case .easy:
            return currentAttempt >= 2 && !hintUsedThisAttempt  // Nach dem zweiten Versuch
        case .medium:
            return currentAttempt >= 3 && !hintUsedThisAttempt  // Nach dem dritten Versuch
        case .hard, .expert:
            return currentAttempt >= 4 && !hintUsedThisAttempt  // Nach dem vierten Versuch
        }
    }
    
    var canShowBestNextGuess: Bool {
        guard gameModel.gameState != .gameOver else {
            return false
        }
        
        let currentAttempt = gameModel.attempts.count
        switch gameModel.difficulty {
        case .easy, .medium:
            return currentAttempt >= 3 && !hintUsedThisAttempt  // Nach dem dritten Versuch
        case .hard, .expert:
            return currentAttempt >= 2 && !hintUsedThisAttempt  // Nach dem zweiten Versuch
        }
    }
    
    func requestBestNextGuess() {
        hintUsedThisAttempt = true
        NotificationCenter.default.post(
            name: Notification.Name("CalculateBestNextGuess"),
            object: gameModel
        )
    }
    
    func showBestNextGuessHint() {
        showHint = true
        hintMessage = gameModel.getBestNextGuess()
    }
    
    func showLetterHint() {
        hintUsedThisAttempt = true
        showHint = true
        hintMessage = gameModel.getLetterHint()
    }
    
    // MARK: - Alert Handling
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Tutorial Handling
    
    func showTutorial(type: TutorialType) {
        selectedTutorialType = type
        showTutorial = true
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .newGameStarted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showAlert = false
            self?.showHint = false
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let newGameStarted = Notification.Name("newGameStarted")
}
