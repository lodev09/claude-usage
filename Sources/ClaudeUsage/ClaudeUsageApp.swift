import SwiftUI

@main
struct ClaudeUsageApp: App {
    @StateObject private var model = UsageModel()

    var body: some Scene {
        MenuBarExtra {
            UsageView(model: model)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "sparkle")
                Text(model.headline)
                    .monospacedDigit()
            }
        }
        .menuBarExtraStyle(.window)

        Window("About Claude Usage", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }
}
