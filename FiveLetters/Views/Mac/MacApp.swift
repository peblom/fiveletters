import SwiftUI
import AppKit

@main
struct FiveLettersMacApp: App {
    @StateObject private var gameController = GameController.shared
    
    var body: some Scene {
        macOSCommands()
    }
    
    func macOSCommands() -> some Scene {
        WindowGroup {
            ContentViewMac()
                .environmentObject(gameController)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Entferne Standard-Menüs
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .undoRedo) { }
            
            // Füge Tastaturkürzel hinzu
            CommandGroup(after: .newItem) {
                Button("Neues Spiel") {
                    gameController.startNewGame()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
