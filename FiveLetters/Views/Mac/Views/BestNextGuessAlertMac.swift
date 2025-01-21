import SwiftUI

struct BestNextGuessAlertMac: View {
    @EnvironmentObject var gameController: GameController
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        AlertViewMac(
            title: "Bester nächster Versuch",
            message: gameController.hintMessage
        )
    }
} 