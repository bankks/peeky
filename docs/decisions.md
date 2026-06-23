# Architecture Decision Records — Peeky

Decisions made during product development. Each entry captures: **context → options considered → decision → consequences**.

---

## ADR-001 — Quick Look Extension vs. standalone app

**Date:** 2026-06-23
**Status:** Decided

**Context:** The goal is to preview `.md` files by pressing Space in Finder. Two main approaches exist:
1. A standalone viewer app registered as the default handler for `.md` files
2. A Quick Look Extension embedded in a container app

**Options considered:**
- Standalone app: more control, but changes the default "open" behavior for `.md` — invasive
- Quick Look Extension: non-invasive, works exactly like macOS native previews (images, PDFs), integrates with Finder's existing Space bar behavior

**Decision:** Quick Look Extension (`com.apple.quicklook.preview`).

**Consequences:** Requires a container app (Apple mandates it), but the container is minimal. The extension registers non-destructively — it doesn't change what editor `.md` files open in.

---

## ADR-002 — Markdown parser: Ink vs. cmark-gfm

**Date:** 2026-06-23
**Status:** Decided

**Context:** Two serious options for parsing Markdown in Swift:
- `cmark-gfm`: C library used by GitHub, full GFM spec (tables, task lists, strikethrough), battle-tested. Complex SPM integration (C target wrapping).
- `Ink` by John Sundell: pure Swift, lightweight, SPM-native, no C dependencies. Covers ~90% of common usage.

**Decision:** Start with **Ink** for the tracer bullet. Migrate to cmark-gfm if we hit spec compliance gaps in real usage.

**Consequences:** Faster iteration in Phase 1. GFM tables and some edge cases may not render perfectly. Acceptable for MVP — switching the renderer is isolated to `MarkdownRenderer.swift`.

---

## ADR-003 — HTML rendering via WKWebView

**Date:** 2026-06-23
**Status:** Decided

**Context:** Options for rendering HTML output inside a Quick Look preview:
- `NSTextView` with AttributedString: native, but limited styling, no syntax highlighting, no CSS
- `WKWebView`: full HTML/CSS/JS engine, dark mode via CSS media queries, highlight.js integration

**Decision:** **WKWebView** with a self-contained HTML template.

**Consequences:** Preview renders with full CSS control. highlight.js can be bundled as a Resource. WKWebView sandbox prevents external network requests by default — all assets must be bundled. This is a feature (offline-first) not a bug.

---

## ADR-004 — macOS target: 14.0 (Sonoma) only

**Date:** 2026-06-23
**Status:** Decided

**Context:** Quick Look Extension APIs available since macOS 10.15. Supporting older versions would require handling deprecated APIs and testing across versions.

**Decision:** macOS 14.0+ only.

**Consequences:** Cuts ~10% of active Mac users (those on 12/13). Acceptable tradeoff: cleaner API surface, no legacy code paths, and target audience (devs who work with AI tools daily) trends toward keeping macOS updated.

---

## ADR-005 — Distribution: GitHub Releases + Homebrew Cask

**Date:** 2026-06-23
**Status:** Decided

**Context:** Three distribution options:
- App Store: $99/year, review process, restrictions on system extensions
- Direct .dmg: full control, but users get "unverified developer" warning without notarization (requires $99/year Developer ID)
- Homebrew Cask: standard for developer tools, `brew install --cask peeky`, community-maintained tap

**Decision:** GitHub Releases (primary) + Homebrew Cask (for discoverability). App Store is a v2+ consideration.

**Consequences:** Notarization required for seamless install experience (no "unverified" dialog). This requires Apple Developer Program enrollment before public release.

---

## ADR-006 — Analytics strategy for open source

**Date:** 2026-06-23
**Status:** Decided

**Context:** Open source projects don't have backend analytics by default. Need to measure adoption without compromising user trust.

**Decision:** Layer 1 (free, automatic): GitHub Insights + Homebrew install counts. Layer 2 (v1.1): opt-in telemetry toggle in Settings — privacy-first, no PII, no persistent IDs. Events: app launch, macOS version, feature flags state.

**Consequences:** MVP ships without telemetry backend. Adoption measured via GitHub stars/forks/clones and Homebrew stats. Quality signal via GitHub Issues.
