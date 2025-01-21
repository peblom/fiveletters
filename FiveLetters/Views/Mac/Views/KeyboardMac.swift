import SwiftUI
import Foundation

struct KeyboardMac: View {
    @EnvironmentObject private var gameController: GameController
    
    private let rows = [
        ["Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Y", "X", "C", "V", "B", "N", "M"],
        ["ENTER", "DELETE"]  // Separate Zeile für Spezial-Tasten
    ]
    
    var body: some View {
        VStack(spacing: Constants.UI.Keyboard.spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: Constants.UI.Keyboard.spacing) {
                    if row == ["ENTER", "DELETE"] {
                        Spacer()
                    }
                    ForEach(row, id: \.self) { key in
                        KeyboardKey(
                            key: key,
                            width: widthForKey(key),
                            action: { handleKeyPress(key) },
                            evaluation: evaluationForKey(key),
                            isEnabled: isKeyEnabled(key)
                        )
                    }
                    if row == ["ENTER", "DELETE"] {
                        Spacer()
                    }
                }
            }
        }
        .padding(8)
    }
    
    private func widthForKey(_ key: String) -> CGFloat {
        switch key {
        case "ENTER", "DELETE":
            return Constants.UI.Keyboard.specialKeyWidth
        default:
            return Constants.UI.Keyboard.tileSize.width
        }
    }
    
    private func evaluationForKey(_ key: String) -> LetterEvaluation {
        if key.count > 1 {
            return .empty
        }
        guard let char = key.first else {
            return .empty
        }
        return gameController.gameModel.getLetterEvaluation(for: char)
    }
    
    private func isKeyEnabled(_ key: String) -> Bool {
        // Spezielle Tasten sind immer aktiviert
        if key == "ENTER" || key == "DELETE" {
            return true
        }
        
        // Im Easy-Modus sind alle Tasten aktiviert
        if gameController.gameModel.difficulty == .easy {
            return true
        }
        
        // Für andere Schwierigkeitsgrade: Deaktiviere Tasten mit absent-Evaluation
        guard let char = key.first,
              let evaluation = evaluationForKey(String(char)) else {
            return true
        }
        
        return evaluation != .absent
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "ENTER":
            gameController.submitAttempt()
        case "DELETE":
            gameController.removeLetter()
        default:
            if isKeyEnabled(key) {
                gameController.addLetter(key)
            }
        }
    }
}

struct KeyboardKey: View {
    let key: String
    let width: CGFloat
    let action: () -> Void
    let evaluation: LetterEvaluation
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text(key)
                .font(.system(size: Constants.UI.Keyboard.fontSize, weight: .medium))
                .foregroundColor(isEnabled ? .white : Constants.UI.Colors.disabledText)
                .frame(width: width, height: Constants.UI.Keyboard.tileSize.height)
                .background(isEnabled ? evaluation.color : Constants.UI.Colors.disabledBackground)
                .cornerRadius(Constants.UI.Keyboard.cornerRadius)
        }
        .buttonStyle(.borderless)
        .focusable(false)
        .disabled(!isEnabled)
    }
}

struct SpecialKeyboardKey: View {
    let title: String
    let onPress: () -> Void
    @Binding var isEnabled: Bool
    
    var body: some View {
        Button(action: onPress) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(
                    width: title == "NEW GAME" ? 
                        Constants.UI.Keyboard.specialKeyWidth * 2 : 
                        Constants.UI.Keyboard.specialKeyWidth,
                    height: Constants.UI.Keyboard.tileSize.height
                )
                .background(backgroundColor)
                .cornerRadius(Constants.UI.Keyboard.cornerRadius)
        }
        .buttonStyle(.borderless)
        .disabled(!isEnabled)
    }
    
    private var backgroundColor: Color {
        if title == "NEW GAME" {
            return Constants.UI.Colors.correct
        }
        if !isEnabled {
            return Constants.UI.Colors.absent
        }
        return Constants.UI.Colors.specialKey
    }
}
