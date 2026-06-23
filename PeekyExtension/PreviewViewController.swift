import Cocoa
import Quartz
import WebKit

@objc(PreviewViewController)
class PreviewViewController: NSViewController, QLPreviewingController {

    private var webView: WKWebView!

    override func loadView() {
        let config = WKWebViewConfiguration()
        // Allow local file access for assets bundled with the extension
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

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
            let settings = Settings.self

            let fullHTML = HTMLTemplate.build(
                body: htmlBody,
                frontMatter: frontMatter,
                theme: settings.theme,
                fontSize: settings.fontSize,
                lineWidth: settings.lineWidth
            )

            // Use the file's directory as baseURL so relative image paths resolve
            webView.loadHTMLString(fullHTML, baseURL: url.deletingLastPathComponent())
            handler(nil)
        } catch {
            handler(error)
        }
    }
}

// MARK: - WKNavigationDelegate

extension PreviewViewController: WKNavigationDelegate {
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

        // Open external URLs in the default browser
        NSWorkspace.shared.open(url)
        decisionHandler(.cancel)
    }
}
