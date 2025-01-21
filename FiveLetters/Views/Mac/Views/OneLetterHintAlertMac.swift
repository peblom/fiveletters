import SwiftUI

struct OneLetterHintAlertMac: View {
    @EnvironmentObject var gameController: GameController
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        AlertViewMac(
            title: "Ein Buchstabe",
            message: gameController.hintMessage
        )
    }
} 