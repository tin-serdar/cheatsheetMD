# CheatsheetMD

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-blue)](https://www.apple.com/macos/)

A macOS menu bar app that displays a customizable keyboard shortcut cheatsheet overlay. Double-press Right Command to toggle. Configured with a simple Markdown file.

## Features

- **Menu bar only** — no Dock icon, no main window. Lives entirely in the system menu bar.
- **Double right Command to show** — double-press the right Command key to open the overlay. It stays visible while held and dismisses on release.
- **Full-screen overlay** — a borderless floating panel covers 95% of the visible screen, centered, with rounded corners.
- **Multi-column layout** — sections are distributed across columns using a masonry algorithm. Column count auto-adjusts based on window width (~280pt per column).
- **Markdown-powered** — the cheatsheet is a plain `.md` file parsed with [swift-markdown](https://github.com/swiftlang/swift-markdown). Supports headings, lists, **bold**, *italic*, and `code` formatting.
- **Edit externally** — click "Edit Cheatsheet..." in the menu bar to open the file in your default text editor. Changes are picked up on next show.
- **Auto-creates default** — on first run, creates `~/.config/cheatsheetmd/cheatsheet.md` with sample macOS shortcuts.
- **Focus restoration** — the previously active app regains focus when the overlay dismisses.

## Installation

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/tin-serdar/cheatsheetMD.git
   cd cheatsheetMD
   ```
2. Open `CheatsheetMD.xcodeproj` in Xcode.
3. Build and run (⌘R).

### Requirements

- macOS 14+ (Sonoma)
- Xcode 16+ (to build from source)
- **Accessibility permission** — required for the CGEvent tap to detect the right Command key globally. The app prompts on first launch.

## Usage

| Action | Trigger |
|---|---|
| Show cheatsheet | Double-press right Command (hold to keep visible) |
| Dismiss cheatsheet | Release right Command |

### Customizing Your Cheatsheet

The cheatsheet lives at `~/.config/cheatsheetmd/cheatsheet.md`. Write standard Markdown with `##` headings for sections and `-` lists for items:

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

You can also click **"Edit Cheatsheet..."** from the menu bar icon to open the file in your default editor.

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

## Configuration

| Setting | Value | Location |
|---|---|---|
| Cheatsheet file | `~/.config/cheatsheetmd/cheatsheet.md` | `CheatsheetManager.swift` |
| Double-press threshold | 400ms | `HotkeyManager.swift` |
| Overlay size | 95% of visible screen | `OverlayPanel.swift` |

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
