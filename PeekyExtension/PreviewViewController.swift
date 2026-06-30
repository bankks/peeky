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
        guard AppSettings.isActive else {
            webView.loadHTMLString(inactiveHTML(), baseURL: nil)
            handler(nil)
            return
        }

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

    private func inactiveHTML() -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
          body { font-family: -apple-system, sans-serif; display: flex; align-items: center;
                 justify-content: center; height: 100vh; margin: 0; background: #F9F9F9;
                 color: #1C1C1E; }
          @media (prefers-color-scheme: dark) {
            body { background: #1C1C1E; color: #F2F2F7; }
            p    { color: #8E8E93; }
          }
          .wrap { text-align: center; }
          h2 { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
          p  { font-size: 14px; color: #6C6C70; margin: 0; }
        </style>
        </head>
        <body>
          <div class="wrap">
            <h2>Peeky is not running</h2>
            <p>Open Peeky.app to enable Markdown previews.</p>
          </div>
        </body>
        </html>
        """
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
