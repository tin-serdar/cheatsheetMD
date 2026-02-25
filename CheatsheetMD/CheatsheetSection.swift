import Foundation
import Markdown

/// A parsed section of the cheatsheet: a heading followed by content items.
struct CheatsheetSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [CheatsheetItem]
}

/// A single rendered item within a section.
struct CheatsheetItem: Identifiable {
    let id = UUID()
    let segments: [TextSegment]
}

/// A segment of styled text within an item.
enum TextSegment: Identifiable {
    case plain(String)
    case bold(String)
    case italic(String)
    case code(String)

    var id: String {
        switch self {
        case .plain(let s): return "p:\(s)"
        case .bold(let s): return "b:\(s)"
        case .italic(let s): return "i:\(s)"
        case .code(let s): return "c:\(s)"
        }
    }
}

// MARK: - Parser

struct CheatsheetParser {

    static func parse(_ markdown: String) -> [CheatsheetSection] {
        let document = Document(parsing: markdown)
        var sections: [CheatsheetSection] = []
        var currentTitle: String? = nil
        var currentItems: [CheatsheetItem] = []

        for child in document.children {
            if let heading = child as? Heading {
                // Flush previous section
                if let title = currentTitle {
                    sections.append(CheatsheetSection(title: title, items: currentItems))
                }
                currentTitle = heading.plainText
                currentItems = []
            } else if let list = child as? UnorderedList {
                for listChild in list.children {
                    if let listItem = listChild as? ListItem {
                        let segments = extractSegments(from: listItem)
                        currentItems.append(CheatsheetItem(segments: segments))
                    }
                }
            } else if let list = child as? OrderedList {
                for listChild in list.children {
                    if let listItem = listChild as? ListItem {
                        let segments = extractSegments(from: listItem)
                        currentItems.append(CheatsheetItem(segments: segments))
                    }
                }
            } else if let paragraph = child as? Paragraph {
                // Treat standalone paragraphs as items too
                let segments = extractInlineSegments(from: paragraph)
                if !segments.isEmpty {
                    currentItems.append(CheatsheetItem(segments: segments))
                }
            }
        }

        // Flush last section
        if let title = currentTitle {
            sections.append(CheatsheetSection(title: title, items: currentItems))
        } else if !currentItems.isEmpty {
            sections.append(CheatsheetSection(title: "", items: currentItems))
        }

        return sections
    }

    private static func extractSegments(from listItem: ListItem) -> [TextSegment] {
        var segments: [TextSegment] = []
        for child in listItem.children {
            if let paragraph = child as? Paragraph {
                segments.append(contentsOf: extractInlineSegments(from: paragraph))
            }
        }
        return segments
    }

    private static func extractInlineSegments(from markup: some Markup) -> [TextSegment] {
        var segments: [TextSegment] = []
        for child in markup.children {
            if let text = child as? Markdown.Text {
                if !text.string.isEmpty {
                    segments.append(.plain(text.string))
                }
            } else if let strong = child as? Strong {
                segments.append(.bold(strong.plainText))
            } else if let emphasis = child as? Emphasis {
                segments.append(.italic(emphasis.plainText))
            } else if let code = child as? InlineCode {
                segments.append(.code(code.code))
            } else if child is SoftBreak || child is LineBreak {
                segments.append(.plain(" "))
            } else {
                // For other inline containers, recurse
                let nested = extractInlineSegments(from: child)
                segments.append(contentsOf: nested)
            }
        }
        return segments
    }
}
