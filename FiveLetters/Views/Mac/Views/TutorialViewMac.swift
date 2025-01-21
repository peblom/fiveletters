import SwiftUI
import WebKit

struct TutorialViewMac: View {
    let type: TutorialType
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Schließen") {
                    dismiss()
                }
                .padding()
            }
            
            WebView(fileName: type.fileName)
        }
        .frame(width: 600, height: 400)
    }
}

struct WebView: NSViewRepresentable {
    let fileName: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        loadContent(in: webView)
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        loadContent(in: webView)
    }
    
    private func loadContent(in webView: WKWebView) {
        if let htmlPath = Bundle.main.path(forResource: fileName, ofType: "html", inDirectory: "Tutorials"),
           let htmlString = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Erlaube nur das Laden von lokalem Content
            if navigationAction.navigationType == .linkActivated {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
} 