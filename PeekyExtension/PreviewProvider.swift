import QuickLookUI
import UniformTypeIdentifiers

class PreviewProvider: QLPreviewProvider {

    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let url = request.fileURL
        let raw = try String(contentsOf: url, encoding: .utf8)
        let (frontMatter, body) = FrontMatterParser.parse(raw)
        let htmlBody = MarkdownRenderer.render(body)
        let html = HTMLTemplate.build(
            body: htmlBody,
            frontMatter: frontMatter,
            theme: AppSettings.theme,
            fontSize: AppSettings.fontSize,
            lineWidth: AppSettings.lineWidth
        )
        let reply = QLPreviewReply(
            dataOfContentType: UTType.html,
            contentSize: CGSize(width: 800, height: 600)
        ) { _ in
            return html.data(using: .utf8) ?? Data()
        }
        return reply
    }
}
