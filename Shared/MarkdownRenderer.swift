import Ink

enum MarkdownRenderer {

    private static let parser = MarkdownParser()

    /// Converts a Markdown string to an HTML fragment (no <html> wrapper).
    static func render(_ markdown: String) -> String {
        parser.html(from: markdown)
    }
}
