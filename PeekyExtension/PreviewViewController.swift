import Cocoa
import Quartz
import WebKit

class PreviewViewController: NSViewController, QLPreviewingController {

    private var webView: WKWebView!
    private var completionHandler: ((Error?) -> Void)?

    /// Highlight.js resources loaded once from the extension bundle.
    private lazy var highlight: (js: String, cssLight: String, cssDark: String) = {
        let bundle = Bundle(for: PreviewViewController.self)
        func read(_ name: String, _ ext: String) -> String {
            guard let url = bundle.url(forResource: name, withExtension: ext),
                  let content = try? String(contentsOf: url, encoding: .utf8) else { return "" }
            return content
        }
        return (
            js: read("highlight.min", "js"),
            cssLight: read("github.min", "css"),
            cssDark: read("github-dark.min", "css")
        )
    }()

    override func loadView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }

    // MARK: - QLPreviewingController

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        do {
            let raw = try String(contentsOf: url, encoding: .utf8)
            let (frontMatter, markdownBody) = FrontMatterParser.parse(raw)
            let htmlBody = MarkdownRenderer.render(markdownBody)

            let fullHTML = HTMLTemplate.build(
                body: htmlBody,
                frontMatter: frontMatter,
                theme: AppSettings.theme,
                fontSize: AppSettings.fontSize,
                lineWidth: AppSettings.lineWidth,
                highlightJS: highlight.js,
                highlightCSSLight: highlight.cssLight,
                highlightCSSDark: highlight.cssDark
            )

            // Store handler — call it only after WebView finishes loading
            self.completionHandler = handler
            // baseURL: nil — HTML is fully self-contained (all CSS inline).
            // Using a file:// base URL triggers a sandbox-blocked navigation in macOS 26.
            webView.loadHTMLString(fullHTML, baseURL: nil)
            // Safety timeout — prevents infinite spinner if WebView fails silently
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.completionHandler?(nil)
                self?.completionHandler = nil
            }
        } catch {
            handler(error)
        }
    }

}

// MARK: - WKNavigationDelegate

extension PreviewViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        completionHandler?(nil)
        completionHandler = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completionHandler?(error)
        completionHandler = nil
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard navigationAction.navigationType == .linkActivated,
              let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        NSWorkspace.shared.open(url)
        decisionHandler(.cancel)
    }
}
