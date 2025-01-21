import SwiftUI

struct GameBoardMac: View {
    @EnvironmentObject private var gameController: GameController
    
    private let spacing = Constants.UI.Board.spacing
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<6) { row in
                rowView(for: row)
            }
        }
        .padding(.top, 20)
    }
    
    private func rowView(for row: Int) -> some View {
        HStack(spacing: spacing) {
            ForEach(0..<5) { col in
                tileView(row: row, col: col)
            }
        }
    }
    
    private func tileView(row: Int, col: Int) -> some View {
        ZStack {
            // Basis-Tile
            LetterTileMac(
                letter: letterAt(row: row, col: col),
                evaluation: evaluationAt(row: row, col: col),
                delay: Double(col) * 0.2,
                isCurrentRow: row == gameController.gameModel.attempts.count,
                isCurrentColumn: col == gameController.gameModel.currentAttempt.count
            )
            
            // Hint-Overlay (später implementieren)
            // if let hintLetter = gameController.activeHintLetter,
            //    row == gameController.currentAttempt &&
            //    col == hintLetter.position {
            //     HintTileMac(letter: String(hintLetter.letter))
            // }
        }
    }
    
    private func letterAt(row: Int, col: Int) -> String {
        let attempts = gameController.gameModel.attempts
        if row < attempts.count {
            return String(Array(attempts[row])[col])
        }
        if row == attempts.count {
            let currentAttempt = gameController.gameModel.currentAttempt
            return col < currentAttempt.count ? String(Array(currentAttempt)[col]) : ""
        }
        return ""
    }
    
    private func evaluationAt(row: Int, col: Int) -> LetterEvaluation {
        let evaluations = gameController.gameModel.evaluations
        if row < evaluations.count {
            return evaluations[row].evaluations[col]
        }
        return .empty
    }
}

struct LetterTileMac: View {
    let letter: String
    let evaluation: LetterEvaluation
    let delay: Double
    let isCurrentRow: Bool
    let isCurrentColumn: Bool
    
    @State private var flipped = false
    @State private var animationComplete = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.UI.Board.cornerRadius)
                .fill(backgroundColor)
                .frame(
                    width: Constants.UI.Board.tileSize.width,
                    height: Constants.UI.Board.tileSize.height
                )
                .rotation3DEffect(
                    .degrees(flipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            Text(letter)
                .font(.system(size: Constants.UI.Board.fontSize, weight: .bold))
                .foregroundColor(.white)
        }
        .onChange(of: evaluation) { oldValue, newValue in
            if newValue != .empty {
                withAnimation(Animation.easeInOut(duration: 0.8).delay(delay)) {
                    flipped = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.4) {
                    animationComplete = true
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        if !animationComplete {
            return Constants.UI.Colors.unused
        }
        return evaluation.color
    }
}
