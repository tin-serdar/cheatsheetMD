import SwiftUI

struct CheatsheetView: View {
    let sections: [CheatsheetSection]
    let columnCount: Int

    init(sections: [CheatsheetSection], columnCount: Int = 0) {
        self.sections = sections
        // 0 means auto-detect from available width
        self.columnCount = columnCount
    }

    var body: some View {
        GeometryReader { geometry in
            let columns = columnCount > 0 ? columnCount : max(1, Int(geometry.size.width / 280))
            let distributed = distributeSections(sections, into: columns)

            HStack(alignment: .top, spacing: 24) {
                ForEach(Array(distributed.enumerated()), id: \.offset) { _, column in
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(column) { section in
                            SectionView(section: section)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
        }
    }

    /// Distribute sections across columns using a greedy shortest-column algorithm.
    private func distributeSections(_ sections: [CheatsheetSection], into columnCount: Int) -> [[CheatsheetSection]] {
        var columns = Array(repeating: [CheatsheetSection](), count: columnCount)
        var heights = Array(repeating: 0, count: columnCount)

        for section in sections {
            // Estimate height: heading + items
            let estimatedHeight = 1 + section.items.count
            // Find the shortest column
            let minIndex = heights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            columns[minIndex].append(section)
            heights[minIndex] += estimatedHeight
        }

        return columns
    }
}

// MARK: - Section View

private struct SectionView: View {
    let section: CheatsheetSection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !section.title.isEmpty {
                Text(section.title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 2)
            }

            ForEach(section.items) { item in
                ItemView(item: item)
            }
        }
    }
}

// MARK: - Item View

private struct ItemView: View {
    let item: CheatsheetItem

    var body: some View {
        Text(attributedString)
            .font(.system(.callout))
            .foregroundStyle(.primary.opacity(0.85))
    }

    private var attributedString: AttributedString {
        var result = AttributedString()
        for segment in item.segments {
            var part: AttributedString
            switch segment {
            case .plain(let str):
                part = AttributedString(str)
            case .bold(let str):
                part = AttributedString(str)
                part.inlinePresentationIntent = .stronglyEmphasized
            case .italic(let str):
                part = AttributedString(str)
                part.inlinePresentationIntent = .emphasized
            case .code(let str):
                part = AttributedString(str)
                part.inlinePresentationIntent = .code
                part.font = .system(.callout, design: .monospaced)
                part.foregroundColor = .accentColor
            }
            result.append(part)
        }
        return result
    }
}
