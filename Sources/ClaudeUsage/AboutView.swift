import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 72, height: 72)

            Text("Claude Usage")
                .font(.title3.bold())

            Text("Version \(version)")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/lodev09/claude-usage")!) {
                    Label("GitHub", systemImage: "curlybraces")
                }
                Link(destination: URL(string: "https://github.com/lodev09")!) {
                    Label("@lodev09", systemImage: "person")
                }
            }
            .font(.callout)

            Text("MIT License © 2026 Jovanni Lo")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(width: 280)
    }
}
