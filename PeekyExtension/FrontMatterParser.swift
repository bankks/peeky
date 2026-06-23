import Foundation

enum FrontMatterParser {

    /// Splits a raw markdown string into a front matter dictionary and the body.
    /// Supports YAML front matter delimited by `---` at the start of the file.
    static func parse(_ raw: String) -> ([String: String], String) {
        let lines = raw.components(separatedBy: "\n")

        // Front matter must start on the very first line
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            return ([:], raw)
        }

        // Find the closing ---
        guard let closingIndex = lines.dropFirst().firstIndex(where: {
            $0.trimmingCharacters(in: .whitespaces) == "---"
        }) else {
            return ([:], raw)
        }

        let yamlLines = lines[1..<closingIndex]
        var meta: [String: String] = [:]

        for line in yamlLines {
            let parts = line.split(separator: ":", maxSplits: 1)
            guard parts.count == 2 else { continue }
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            meta[key] = value
        }

        let bodyLines = lines[(closingIndex + 1)...]
        let body = bodyLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        return (meta, body)
    }
}
