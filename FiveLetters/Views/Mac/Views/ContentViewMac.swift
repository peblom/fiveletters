import SwiftUI
import AppKit

struct ContentViewMac: View {
    @EnvironmentObject var gameController: GameController
    
    private var screenHeight: CGFloat {
        NSScreen.main?.frame.height ?? 800
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Menüleiste
                GameMenuMac()
                
                Spacer()
                
                // Spielbrett
                GameBoardMac()
                    .frame(height: screenHeight * 0.6)
                
                Spacer()
                
                // Tastatur
                KeyboardMac()
                    .frame(height: screenHeight * 0.25)
                    .padding(.bottom, 20)
                
                // Neues Spiel Button (nur wenn Spiel beendet)
                if gameController.gameModel.isGameOver {
                    Button("Neues Spiel") {
                        gameController.startNewGame()
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 10)
                }
            }
        }
        .alert(gameController.alertTitle, isPresented: $gameController.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(gameController.alertMessage)
        }
        .sheet(isPresented: $gameController.showTutorial) {
            TutorialViewMac(type: gameController.selectedTutorialType)
        }
        .sheet(isPresented: $gameController.showHint) {
            HintView(message: gameController.hintMessage)
        }
    }
}
