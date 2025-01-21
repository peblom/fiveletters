import SwiftUI

struct PossibleSolutionsAlertMac: View {
    @EnvironmentObject var gameController: GameController
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        AlertViewMac(
            title: "Mögliche Lösungen",
            message: gameController.hintMessage
        )
    }
} 