import AppKit
import Foundation

let sizes: [(name: String, px: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

func drawIcon(px: Int) -> NSBitmapImageRep {
    let size = CGFloat(px)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: px, pixelsHigh: px,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 32
    )!

    NSGraphicsContext.saveGraphicsState()
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    ctx.imageInterpolation = .high
    NSGraphicsContext.current = ctx

    let inset = size * 0.10
    let bounds = NSRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let radius = bounds.width * 0.225
    let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)

    let shadow = NSShadow()
    shadow.shadowColor = NSColor(white: 0, alpha: 0.25)
    shadow.shadowBlurRadius = size * 0.04
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.015)
    shadow.set()
    NSColor.black.withAlphaComponent(0.001).setFill()
    path.fill()

    NSShadow().set()

    NSGraphicsContext.current?.saveGraphicsState()
    path.addClip()

    let gradient = NSGradient(colors: [
        NSColor(srgbRed: 0.32, green: 0.53, blue: 0.99, alpha: 1.0),
        NSColor(srgbRed: 0.44, green: 0.31, blue: 0.88, alpha: 1.0),
    ])!
    gradient.draw(in: bounds, angle: -65)

    if let hi = NSGradient(colors: [
        NSColor(white: 1, alpha: 0.18),
        NSColor(white: 1, alpha: 0.0),
    ]) {
        hi.draw(in: NSRect(x: bounds.minX, y: bounds.midY, width: bounds.width, height: bounds.height / 2), angle: 90)
    }

    let fontSize = bounds.width * 0.58
    let font = NSFont.systemFont(ofSize: fontSize, weight: .heavy)
    let mAttrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
        .kern: -fontSize * 0.03,
    ]
    let m = NSAttributedString(string: "M", attributes: mAttrs)
    let mSize = m.size()
    let mRect = NSRect(
        x: bounds.midX - mSize.width / 2,
        y: bounds.midY - mSize.height / 2 + bounds.height * 0.06,
        width: mSize.width,
        height: mSize.height
    )
    m.draw(in: mRect)

    let chev = NSBezierPath()
    let cw = bounds.width * 0.28
    let ch = bounds.width * 0.12
    let cx = bounds.midX
    let cy = bounds.minY + bounds.height * 0.18
    chev.move(to: NSPoint(x: cx - cw / 2, y: cy + ch / 2))
    chev.line(to: NSPoint(x: cx, y: cy - ch / 2))
    chev.line(to: NSPoint(x: cx + cw / 2, y: cy + ch / 2))
    chev.lineWidth = max(2, bounds.width * 0.055)
    chev.lineCapStyle = .round
    chev.lineJoinStyle = .round
    NSColor.white.withAlphaComponent(0.95).setStroke()
    chev.stroke()

    NSGraphicsContext.current?.restoreGraphicsState()
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write(Data("usage: make-icon.swift <output-iconset-dir>\n".utf8))
    exit(1)
}
let outDir = args[1]
let fm = FileManager.default
try? fm.createDirectory(atPath: outDir, withIntermediateDirectories: true)

for (name, px) in sizes {
    let rep = drawIcon(px: px)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write(Data("failed to encode \(name)\n".utf8))
        continue
    }
    let url = URL(fileURLWithPath: outDir).appendingPathComponent(name)
    try data.write(to: url)
    print("wrote \(url.path) (\(px)px)")
}
