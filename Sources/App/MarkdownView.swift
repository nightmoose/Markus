import SwiftUI
import WebKit

struct MarkdownView: NSViewRepresentable {
    let text: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.suppressesIncrementalRendering = false

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        webView.allowsMagnification = true
        context.coordinator.webView = webView
        context.coordinator.pendingMarkdown = text
        loadTemplate(into: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingMarkdown = text
        if context.coordinator.templateLoaded {
            context.coordinator.pushMarkdown(text)
        }
    }

    private func loadTemplate(into webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: "template", withExtension: "html") else {
            webView.loadHTMLString("<h1>Missing template.html</h1>", baseURL: nil)
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        var templateLoaded = false
        var pendingMarkdown: String = ""

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            templateLoaded = true
            pushMarkdown(pendingMarkdown)
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func pushMarkdown(_ md: String) {
            guard let webView = webView else { return }
            let payload = jsString(md)
            webView.evaluateJavaScript("window.setMarkdown(\(payload));", completionHandler: nil)
        }

        private func jsString(_ s: String) -> String {
            let data = try? JSONSerialization.data(withJSONObject: [s], options: [])
            guard let data, let arr = String(data: data, encoding: .utf8) else { return "\"\"" }
            let inner = arr.dropFirst().dropLast()
            return String(inner)
        }
    }
}
