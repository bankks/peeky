import Foundation
import Quartz
import UniformTypeIdentifiers

@_cdecl("GeneratePreviewForURL")
public func GeneratePreviewForURL(
    _ thisInterface: UnsafeMutableRawPointer?,
    _ preview: QLPreviewRequest,
    _ url: CFURL,
    _ uti: CFString,
    _ options: CFDictionary
) -> OSStatus {
    let fileURL = url as URL
    guard let raw = try? String(contentsOf: fileURL, encoding: .utf8) else { return noErr }

    let (frontMatter, body) = FrontMatterParser.parse(raw)
    let htmlBody = MarkdownRenderer.render(body)
    let html = HTMLTemplate.build(
        body: htmlBody,
        frontMatter: frontMatter,
        theme: AppSettings.theme,
        fontSize: AppSettings.fontSize,
        lineWidth: AppSettings.lineWidth
    )

    guard let data = html.data(using: .utf8) else { return noErr }

    let htmlUTI = UTType.html.identifier as CFString
    let props = ["kQLPreviewPropertyTextEncodingName": "UTF-8"] as CFDictionary
    QLPreviewRequestSetDataRepresentation(preview, data as CFData, htmlUTI, props)

    return noErr
}

@_cdecl("CancelPreviewGeneration")
public func CancelPreviewGeneration(
    _ thisInterface: UnsafeMutableRawPointer?,
    _ preview: QLPreviewRequest
) {}
