import SwiftUI

struct AlertViewMac: View {
    let title: String
    let message: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
            
            Text(message)
                .multilineTextAlignment(.center)
            
            Button("OK") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(width: 300)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .cornerRadius(10)
    }
}
