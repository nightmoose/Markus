import Foundation
import CoreServices
import UniformTypeIdentifiers

// Must match PRODUCT_BUNDLE_IDENTIFIER in project.yml.
let bundleID = "com.nightmoose.markus"
let mdUTIs = ["net.daringfireball.markdown"]

func handler(uti: String, role: LSRolesMask) -> String {
    (LSCopyDefaultRoleHandlerForContentType(uti as CFString, role)?.takeRetainedValue() as String?) ?? "(none)"
}

func handlerForURL(_ url: URL) -> String {
    guard let u = LSCopyDefaultApplicationURLForURL(url as CFURL, .all, nil)?.takeRetainedValue() as URL? else {
        return "(none)"
    }
    return u.path
}

if CommandLine.arguments.contains("--set") {
    for uti in mdUTIs {
        let s1 = LSSetDefaultRoleHandlerForContentType(uti as CFString, .all, bundleID as CFString)
        let s2 = LSSetDefaultRoleHandlerForContentType(uti as CFString, .viewer, bundleID as CFString)
        let s3 = LSSetDefaultRoleHandlerForContentType(uti as CFString, .editor, bundleID as CFString)
        print("set \(uti) all=\(s1) viewer=\(s2) editor=\(s3) → \(bundleID)")
    }
}

for uti in mdUTIs {
    print("\(uti):")
    print("  all    = \(handler(uti: uti, role: .all))")
    print("  viewer = \(handler(uti: uti, role: .viewer))")
    print("  editor = \(handler(uti: uti, role: .editor))")
}

// Pass a path to any .md file to see which app would open it (defaults to ./README.md).
let samplePath = CommandLine.arguments.dropFirst().first { !$0.hasPrefix("--") } ?? "README.md"
let sampleURL = URL(fileURLWithPath: samplePath)
print("\nApp that would open \(samplePath): \(handlerForURL(sampleURL))")
