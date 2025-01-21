import Foundation
import SwiftUI

// Hauptzustände des Spiels
enum GameState {
    case notStarted    // Spiel noch nicht begonnen
    case playing      // Aktives Spiel
    case won         // Spieler hat gewonnen
    case lost        // Spieler hat verloren
}

// Schwierigkeitsgrade
enum Difficulty: String {
    case easy = "Easy"        // Einfach: Keine besonderen Einschränkungen
    case medium = "Medium"    // Mittel: Keine bereits als falsch markierten Buchstaben
    case hard = "Hard"       // Schwer: Korrekte Buchstaben müssen verwendet werden
    case expert = "Expert"   // Experte: Zusätzlich müssen "present" Buchstaben an neuer Position verwendet werden
}

// Status der Buchstabenevaluierung
enum LetterEvaluation: Equatable, CustomStringConvertible {
    case correct     // Buchstabe korrekt und an richtiger Position
    case present     // Buchstabe im Wort, aber falsche Position
    case absent      // Buchstabe nicht im Wort
    case empty      // Noch nicht verwendet
    
    var color: Color {
        switch self {
        case .correct: return Constants.UI.Colors.correct
        case .present: return Constants.UI.Colors.present
        case .absent: return Constants.UI.Colors.absent
        case .empty: return Constants.UI.Colors.unused
        }
    }
    
    var description: String {
        switch self {
        case .correct: return "✅"
        case .present: return "🟡"
        case .absent: return "⬛"
        case .empty: return "⬜"
        }
    }
}

// Tutorial-Typen
enum TutorialType: String {
    case rules = "Rules"
    case levels = "Levels"
    case hints = "Hints"
    
    var title: String {
        switch self {
        case .rules: return "Spielregeln"
        case .levels: return "Schwierigkeitsgrade"
        case .hints: return "Hilfreiche Hinweise"
        }
    }
}

// Struktur für die Bewertung eines Versuchs
struct AttemptEvaluation {
    let word: String
    let evaluations: [LetterEvaluation]
    let isValid: Bool
    let violationMessage: String?
    
    init(word: String, evaluations: [LetterEvaluation], isValid: Bool = true, violationMessage: String? = nil) {
        self.word = word
        self.evaluations = evaluations
        self.isValid = isValid
        self.violationMessage = violationMessage
    }
}

// Alert-Konfiguration
struct AlertConfig {
    let title: String
    var message: String
    let buttonTitle: String
    let buttonColor: Color
    let autoDismissDelay: Double
    let dismissOnOutsideClick: Bool
    let action: () -> Void
    
    static func standard(message: String, action: @escaping () -> Void = {}) -> AlertConfig {
        AlertConfig(
            title: "",
            message: message,
            buttonTitle: "OK",
            buttonColor: .blue,
            autoDismissDelay: 0,
            dismissOnOutsideClick: true,
            action: action
        )
    }
}
