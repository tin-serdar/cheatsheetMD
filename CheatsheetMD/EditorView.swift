import SwiftUI

struct EditorView: View {
    @Bindable var cheatsheetManager: CheatsheetManager
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("CheatsheetMD")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(cheatsheetManager.filePath.path)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Markdown editor
            TextEditor(text: $cheatsheetManager.content)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(16)
                .onChange(of: cheatsheetManager.content) {
                    cheatsheetManager.scheduleSave()
                }
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.93))
    }
}
