import Foundation

enum HTMLTemplate {

    static func build(
        body: String,
        frontMatter: [String: String],
        theme: Settings.Theme,
        fontSize: Int,
        lineWidth: Int
    ) -> String {
        let themeClass: String
        switch theme {
        case .light:  themeClass = "theme-light"
        case .dark:   themeClass = "theme-dark"
        case .system: themeClass = ""
        }

        let frontMatterHTML = frontMatterBlock(frontMatter)

        return """
        <!DOCTYPE html>
        <html lang="en" class="\(themeClass)">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            \(css(fontSize: fontSize, lineWidth: lineWidth))
          </style>
        </head>
        <body>
          <main>
            \(frontMatterHTML)
            \(body)
          </main>
          <script>
            \(highlightScript())
          </script>
        </body>
        </html>
        """
    }

    // MARK: - Front matter header block

    private static func frontMatterBlock(_ meta: [String: String]) -> String {
        guard !meta.isEmpty else { return "" }

        let priorityKeys = ["title", "date", "tags", "author", "description"]
        let orderedKeys = priorityKeys.filter { meta[$0] != nil }
            + meta.keys.filter { !priorityKeys.contains($0) }.sorted()

        let rows = orderedKeys.compactMap { key -> String? in
            guard let value = meta[key] else { return nil }
            return "<tr><td class=\"fm-key\">\(key)</td><td class=\"fm-val\">\(value)</td></tr>"
        }.joined(separator: "\n")

        return """
        <div class="front-matter">
          <table>\(rows)</table>
        </div>
        """
    }

    // MARK: - Inline highlight (no CDN)

    /// Minimal syntax highlight using <pre><code> class detection and CSS only.
    /// Full highlight.js can be bundled as a Resource and injected here later.
    private static func highlightScript() -> String {
        // Phase 1 tracer bullet: no JS syntax highlighting yet.
        // highlight.js will be added as a bundled Resource in the next iteration.
        return ""
    }

    // MARK: - CSS

    private static func css(fontSize: Int, lineWidth: Int) -> String {
        """
        /* ── Variables ─────────────────────────────────────────────── */
        :root {
          --font-body: -apple-system, "Helvetica Neue", Arial, sans-serif;
          --font-mono: "SF Mono", "Menlo", "Consolas", monospace;
          --font-size: \(fontSize)px;
          --line-width: \(lineWidth)px;
          --radius: 6px;

          /* Light palette */
          --bg:         #ffffff;
          --surface:    #f6f8fa;
          --border:     #d1d9e0;
          --text:       #1f2328;
          --text-muted: #636c76;
          --link:       #0969da;
          --code-bg:    #f6f8fa;
          --code-text:  #1f2328;
          --fm-bg:      #f0f6ff;
          --fm-border:  #c8d8f0;
          --hr:         #d1d9e0;
          --blockquote: #636c76;
          --blockquote-border: #d1d9e0;
        }

        @media (prefers-color-scheme: dark) {
          :root:not(.theme-light) {
            --bg:         #0d1117;
            --surface:    #161b22;
            --border:     #30363d;
            --text:       #e6edf3;
            --text-muted: #8b949e;
            --link:       #58a6ff;
            --code-bg:    #161b22;
            --code-text:  #e6edf3;
            --fm-bg:      #0d1f3c;
            --fm-border:  #1f4080;
            --hr:         #21262d;
            --blockquote: #8b949e;
            --blockquote-border: #3d444d;
          }
        }

        .theme-dark {
          --bg:         #0d1117;
          --surface:    #161b22;
          --border:     #30363d;
          --text:       #e6edf3;
          --text-muted: #8b949e;
          --link:       #58a6ff;
          --code-bg:    #161b22;
          --code-text:  #e6edf3;
          --fm-bg:      #0d1f3c;
          --fm-border:  #1f4080;
          --hr:         #21262d;
          --blockquote: #8b949e;
          --blockquote-border: #3d444d;
        }

        /* ── Reset ──────────────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        /* ── Base ───────────────────────────────────────────────────── */
        html { font-size: var(--font-size); background: var(--bg); color: var(--text); }

        body {
          font-family: var(--font-body);
          line-height: 1.7;
          padding: 48px 24px 80px;
          background: var(--bg);
          color: var(--text);
        }

        main {
          max-width: var(--line-width);
          margin: 0 auto;
        }

        /* ── Front matter ───────────────────────────────────────────── */
        .front-matter {
          background: var(--fm-bg);
          border: 1px solid var(--fm-border);
          border-radius: var(--radius);
          padding: 12px 16px;
          margin-bottom: 32px;
          font-size: 0.85em;
        }
        .front-matter table { border-collapse: collapse; width: 100%; }
        .front-matter td { padding: 3px 8px 3px 0; vertical-align: top; }
        .front-matter .fm-key {
          color: var(--text-muted);
          font-family: var(--font-mono);
          white-space: nowrap;
          min-width: 80px;
        }
        .front-matter .fm-val { color: var(--text); }

        /* ── Headings ───────────────────────────────────────────────── */
        h1, h2, h3, h4, h5, h6 {
          font-weight: 600;
          line-height: 1.25;
          margin-top: 1.5em;
          margin-bottom: 0.5em;
        }
        h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid var(--border); }
        h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid var(--border); }
        h3 { font-size: 1.25em; }
        h4 { font-size: 1em; }

        /* ── Paragraph ──────────────────────────────────────────────── */
        p { margin-bottom: 1em; }

        /* ── Links ──────────────────────────────────────────────────── */
        a { color: var(--link); text-decoration: none; }
        a:hover { text-decoration: underline; }

        /* ── Lists ──────────────────────────────────────────────────── */
        ul, ol { padding-left: 2em; margin-bottom: 1em; }
        li { margin-bottom: 0.25em; }
        li > ul, li > ol { margin-top: 0.25em; margin-bottom: 0; }

        /* ── Code ───────────────────────────────────────────────────── */
        code {
          font-family: var(--font-mono);
          font-size: 0.875em;
          background: var(--code-bg);
          color: var(--code-text);
          padding: 0.2em 0.4em;
          border-radius: 4px;
          border: 1px solid var(--border);
        }

        pre {
          background: var(--code-bg);
          border: 1px solid var(--border);
          border-radius: var(--radius);
          padding: 16px;
          overflow-x: auto;
          margin-bottom: 1em;
          line-height: 1.5;
        }
        pre code {
          background: none;
          border: none;
          padding: 0;
          font-size: 0.875em;
        }

        /* ── Blockquote ─────────────────────────────────────────────── */
        blockquote {
          border-left: 4px solid var(--blockquote-border);
          color: var(--blockquote);
          padding: 0 1em;
          margin: 0 0 1em;
        }

        /* ── HR ─────────────────────────────────────────────────────── */
        hr {
          border: none;
          border-top: 1px solid var(--hr);
          margin: 2em 0;
        }

        /* ── Tables ─────────────────────────────────────────────────── */
        table {
          border-collapse: collapse;
          width: 100%;
          margin-bottom: 1em;
          font-size: 0.9em;
        }
        th, td {
          border: 1px solid var(--border);
          padding: 8px 12px;
          text-align: left;
        }
        th {
          background: var(--surface);
          font-weight: 600;
        }
        tr:nth-child(even) { background: var(--surface); }

        /* ── Images ─────────────────────────────────────────────────── */
        img {
          max-width: 100%;
          border-radius: var(--radius);
          display: block;
          margin: 1em auto;
        }

        /* ── Task list ──────────────────────────────────────────────── */
        input[type="checkbox"] {
          margin-right: 6px;
          accent-color: var(--link);
        }
        """
    }
}
