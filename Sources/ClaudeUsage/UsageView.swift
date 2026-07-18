import SwiftUI

struct UsageView: View {
    @ObservedObject var model: UsageModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            Divider()

            if let error = model.error, model.snapshot.limits.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(model.snapshot.limits) { limit in
                        LimitRow(limit: limit)
                    }

                    if let extra = model.snapshot.extraUsage {
                        HStack {
                            Text("Extra usage")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(extra)
                                .font(.subheadline.weight(.medium))
                                .monospacedDigit()
                        }
                    }
                }
                .padding(14)
            }

            Divider()
            footer
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
        .frame(width: 340)
        .onAppear { model.refresh(force: true) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle")
                    .foregroundStyle(.orange)
                Text("Claude Usage")
                    .font(.headline)
                Spacer()
                if let tier = model.tierLabel {
                    Text(tier)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
            }

            if let profile = model.profile {
                HStack(spacing: 10) {
                    AsyncImage(url: profile.avatarURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.95, green: 0.58, blue: 0.42), Color(red: 0.85, green: 0.47, blue: 0.34)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .overlay {
                                Text(profile.name?.prefix(1) ?? "?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        if let name = profile.name {
                            Text(name)
                                .font(.caption.weight(.semibold))
                        }
                        if let email = profile.email {
                            Text(email)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if let org = profile.organization {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(org)
                                .font(.caption.weight(.semibold))
                            if let type = profile.organizationType {
                                Text(type)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(10)
                .background(.quinary, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var footer: some View {
        HStack {
            if model.isLoading {
                ProgressView()
                    .controlSize(.mini)
            } else if let error = model.error, model.snapshot.fetchedAt == nil {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .lineLimit(1)
            } else if let fetched = model.snapshot.fetchedAt {
                Text("Updated \(fetched.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Button {
                model.refresh(force: true)
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .help("Refresh")

            Menu {
                Button("Settings…") {
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                }
                Button("About Claude Usage") {
                    openWindow(id: "about")
                    NSApp.activate(ignoringOtherApps: true)
                }
                Divider()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            } label: {
                Image(systemName: "gearshape")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
    }
}

private struct LimitRow: View {
    let limit: LimitInfo

    private var color: Color {
        switch limit.percent {
        case ..<50: .green
        case ..<75: .yellow
        case ..<90: .orange
        default: .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text(limit.title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(Int(limit.percent))%")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [color.opacity(0.6), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: max(6, geo.size.width * min(limit.percent, 100) / 100))
                }
            }
            .frame(height: 6)
            .animation(.spring(duration: 0.5), value: limit.percent)

            if let resets = limit.resetsAt {
                TimelineView(.everyMinute) { _ in
                    Text("Resets in \(countdown(to: resets))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func countdown(to date: Date) -> String {
        let seconds = Int(max(0, date.timeIntervalSinceNow))
        let days = seconds / 86400
        let hours = seconds % 86400 / 3600
        let minutes = seconds % 3600 / 60
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
