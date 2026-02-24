import SwiftUI

@main
struct CheatsheetMDApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("CheatsheetMD", systemImage: "doc.text") {
            MenuBarView(appState: appState)
        }
    }
}
