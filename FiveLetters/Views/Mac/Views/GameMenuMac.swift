import SwiftUI

struct GameMenuMac: View {
    @EnvironmentObject var gameController: GameController
    
    var body: some View {
        HStack {
            // Tutorial Menü - immer alle aktiv
            Menu("Tutorial") {
                Button("Regeln") {
                    gameController.showTutorial(type: .rules)
                }
                Button("Schwierigkeitsgrade") {
                    gameController.showTutorial(type: .levels)
                }
                Button("Hinweise") {
                    gameController.showTutorial(type: .hints)
                }
            }
            .menuStyle(.button)
            .frame(width: 100)
            
            // Schwierigkeitsgrad Menü - zeigt aktuelles Level und Haken
            Menu("Level: \(gameController.gameModel.difficulty.rawValue)") {
                Group {
                    Button("Einfach") {
                        gameController.setDifficulty(.easy)
                    }
                    .labelStyle(.titleAndIcon)
                    .if(gameController.gameModel.difficulty == .easy) { view in
                        view.image(systemName: "checkmark")
                    }
                    
                    Button("Mittel") {
                        gameController.setDifficulty(.medium)
                    }
                    .labelStyle(.titleAndIcon)
                    .if(gameController.gameModel.difficulty == .medium) { view in
                        view.image(systemName: "checkmark")
                    }
                    
                    Button("Schwer") {
                        gameController.setDifficulty(.hard)
                    }
                    .labelStyle(.titleAndIcon)
                    .if(gameController.gameModel.difficulty == .hard) { view in
                        view.image(systemName: "checkmark")
                    }
                    
                    Button("Experte") {
                        gameController.setDifficulty(.expert)
                    }
                    .labelStyle(.titleAndIcon)
                    .if(gameController.gameModel.difficulty == .expert) { view in
                        view.image(systemName: "checkmark")
                    }
                }
            }
            .menuStyle(.button)
            .frame(width: 140)
            
            // Hinweis Menü - bedingt aktiviert
            Menu("Hinweise") {
                Button("Ein Buchstabe") {
                    if gameController.canUseOneLetterHint {
                        gameController.showLetterHint()
                    }
                }
                .disabled(!gameController.canUseOneLetterHint)
                
                Button("Bester nächster Versuch") {
                    if gameController.canShowBestNextGuess {
                        gameController.requestBestNextGuess()
                    }
                }
                .disabled(!gameController.canShowBestNextGuess)
            }
            .menuStyle(.button)
            .frame(width: 100)
        }
        .padding(.top, 10)
    }
}

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
