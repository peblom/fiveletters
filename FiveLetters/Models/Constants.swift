import SwiftUI

struct Constants {
    // Spielkonstanten
    struct Game {
        static let maxAttempts = 6
        static let wordLength = 5
        static let defaultDifficulty: Difficulty = .easy
        static let minimumWordLength = 5
        static let maximumWordLength = 5
    }
    
    // UI-Konstanten
    struct UI {
        // Farben
        struct Colors {
            static let background = Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.8)
            static let unused = Color(red: 0.2, green: 0.2, blue: 0.2)
            static let correct = Color(red: 0.3, green: 0.73, blue: 0.4).opacity(0.5)
            static let present = Color(red: 0.85, green: 0.73, blue: 0.3).opacity(0.5)
            static let absent = Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5)
            static let specialKey = Color(red: 0.3, green: 0.5, blue: 0.9)
            static let tutorial = Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.95)
            static let disabledBackground = Color.black
            static let disabledText = Color(red: 0.3, green: 0.3, blue: 0.3)
        }
        
        // Board-Größen
        struct Board {
            static let tileSize = CGSize(width: 50, height: 50)
            static let spacing: CGFloat = 8
            static let cornerRadius: CGFloat = 4
            static let fontSize: CGFloat = 26
        }
        
        // Keyboard-Größen
        struct Keyboard {
            static let tileSize = CGSize(width: 35, height: 45)
            static let spacing: CGFloat = 6
            static let cornerRadius: CGFloat = 4
            static let specialKeyWidth: CGFloat = 75
            static let fontSize: CGFloat = 16
            
            static var totalWidth: CGFloat {
                10 * tileSize.width + 9 * spacing
            }
        }
    }
    
    // Textnachrichten
    struct Messages {
        static let gameWon = "Gratulation! Sie haben gewonnen!"
        static let gameLost = "Leider verloren. Versuchen Sie es erneut!"
        static let invalidWord = "Ungültiges Wort"
        static let wordNotInList = "Wort nicht in der Liste"
        static let letterMustBeUsed = "Buchstabe muss verwendet werden"
        static let letterWrongPosition = "Buchstabe an falscher Position"
    }
    
    // Dateinamen
    struct FileNames {
        static let wordList = "wordlist"
        static let acceptedWords = "accepted_words"
        static let statistics = "statistics"
        static let settings = "settings"
    }
}

// Hilfserweiterung für Color mit Hex-Werten
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
