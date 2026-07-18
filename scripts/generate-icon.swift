// Generates AppIcon.icns — run: swift scripts/generate-icon.swift
import AppKit

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    // Squircle background, macOS icon grid (~80% canvas, ~22.5% corner radius)
    let inset = size * 0.1
    let rect = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let radius = rect.width * 0.225
    let squircle = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

    NSGradient(
        starting: NSColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1),
        ending: NSColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)
    )!.draw(in: squircle, angle: -90)

    let coral = NSColor(red: 0.85, green: 0.47, blue: 0.34, alpha: 1) // Claude coral

    // Sparkle: 4-point star, concave sides (quad curves pulled to center)
    func sparkle(center: NSPoint, radius: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        let points = [
            NSPoint(x: center.x, y: center.y + radius),
            NSPoint(x: center.x + radius, y: center.y),
            NSPoint(x: center.x, y: center.y - radius),
            NSPoint(x: center.x - radius, y: center.y),
        ]
        let pull: CGFloat = 0.18
        path.move(to: points[0])
        for i in 0..<4 {
            let next = points[(i + 1) % 4]
            let control = NSPoint(
                x: center.x + (points[i].x + next.x - 2 * center.x) * pull,
                y: center.y + (points[i].y + next.y - 2 * center.y) * pull
            )
            path.curve(to: next, controlPoint1: control, controlPoint2: control)
        }
        path.close()
        return path
    }

    let sparkleCenter = NSPoint(x: size * 0.5, y: size * 0.58)
    NSGradient(
        starting: NSColor(red: 0.95, green: 0.58, blue: 0.42, alpha: 1),
        ending: coral
    )!.draw(in: sparkle(center: sparkleCenter, radius: size * 0.21), angle: -90)

    coral.withAlphaComponent(0.8).setFill()
    sparkle(center: NSPoint(x: size * 0.68, y: size * 0.72), radius: size * 0.07).fill()

    // Progress bar
    let barWidth = rect.width * 0.56
    let barHeight = size * 0.045
    let barRect = NSRect(x: (size - barWidth) / 2, y: size * 0.26, width: barWidth, height: barHeight)
    NSColor.white.withAlphaComponent(0.18).setFill()
    NSBezierPath(roundedRect: barRect, xRadius: barHeight / 2, yRadius: barHeight / 2).fill()
    var fillRect = barRect
    fillRect.size.width = barWidth * 0.62
    coral.setFill()
    NSBezierPath(roundedRect: fillRect, xRadius: barHeight / 2, yRadius: barHeight / 2).fill()

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, pixels: Int, to url: URL) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: url)
}

let iconset = URL(fileURLWithPath: "AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try! FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

for base in [16, 32, 128, 256, 512] {
    writePNG(drawIcon(size: CGFloat(base)), pixels: base, to: iconset.appendingPathComponent("icon_\(base)x\(base).png"))
    writePNG(drawIcon(size: CGFloat(base)), pixels: base * 2, to: iconset.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}
print("iconset written")
