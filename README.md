# CheatsheetMD

A macOS menu-bar-only app that displays a custom cheatsheet overlay. Double-press the right Command key to peek at your shortcuts — release to dismiss.

## Features

- **Menu bar only** — no Dock icon, no main window. Lives entirely in the system menu bar.
- **Double right Command to show** — double-press the right Command key to open the overlay. It stays visible while held and dismisses on release.
- **90%+ screen overlay** — a borderless floating panel covers 95% of the visible screen, centered, with rounded corners and a warm off-white background.
- **Multi-column layout** — sections are distributed across columns using a masonry algorithm. Column count auto-adjusts based on window width (~280pt per column).
- **Markdown-powered** — the cheatsheet is a plain `.md` file parsed with [swift-markdown](https://github.com/swiftlang/swift-markdown). Supports headings, lists, **bold**, *italic*, and `code` formatting.
- **Edit externally** — click "Edit Cheatsheet..." in the menu bar to open the file in your default text editor. Changes are picked up on next show.
- **Auto-creates default** — on first run, creates `~/.config/cheatsheetmd/cheatsheet.md` with sample macOS shortcuts.
- **Focus restoration** — the previously active app regains focus when the overlay dismisses.

## Keyboard Interaction

| Action | Trigger |
|---|---|
| Show cheatsheet | Double-press right Command (hold to keep visible) |
| Dismiss cheatsheet | Release right Command |

## Markdown Format

Write standard markdown with `##` headings for sections and `-` lists for items:

```markdown
## Git
- **git status** — Show working tree status
- **git add .** — Stage all changes
- **git commit -m "msg"** — Commit with message

## Vim
- **:w** — Save
- **:q** — Quit
- **dd** — Delete line
- **yy** — Yank (copy) line
```

Supports: `## Headings` (sections), `- List items`, `**bold**`, `*italic*`, `` `code` ``.

## Architecture

| File | Purpose |
|---|---|
| `CheatsheetMDApp.swift` | Entry point — `MenuBarExtra` scene, no `WindowGroup` |
| `AppState.swift` | Central `@Observable` object owning all managers |
| `CheatsheetManager.swift` | Loads the `.md` file from `~/.config/cheatsheetmd/` |
| `CheatsheetSection.swift` | Data model + parser using swift-markdown AST walker |
| `CheatsheetView.swift` | Multi-column masonry layout with dividers |
| `OverlayPanel.swift` | Borderless floating `NSPanel` + controller |
| `HotkeyManager.swift` | CGEvent tap detecting right Command double-press |
| `MenuBarView.swift` | Menu bar dropdown UI |

## Requirements

- macOS 14+ (Sonoma)
- **Accessibility permission** — required for the CGEvent tap to detect the right Command key globally. The app prompts on first launch.
- **App Sandbox disabled** — CGEvent taps and `~/.config/` file access require running outside the sandbox.

## Configuration

- Cheatsheet file: `~/.config/cheatsheetmd/cheatsheet.md`
- Double-press threshold: 400ms (hardcoded in `HotkeyManager.swift`)
- Overlay size: 95% of visible screen (configurable in `OverlayPanel.swift`)
