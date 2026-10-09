import SwiftUI
import UniformTypeIdentifiers
import AppKit

@main
struct MarkusApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            DocumentView(document: file.document)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                NewFromClipboardButton()
            }
        }

        WindowGroup(id: "scratch", for: ScratchPayload.self) { $payload in
            if let payload {
                DocumentView(document: MarkdownDocument(text: payload.text))
                    .navigationTitle("Pasted Markdown")
            }
        }
    }
}

struct ScratchPayload: Codable, Hashable {
    var id: UUID
    var text: String
}

private struct NewFromClipboardButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("New from Clipboard") {
            let text = NSPasteboard.general.string(forType: .string) ?? ""
            openWindow(id: "scratch", value: ScratchPayload(id: UUID(), text: text))
        }
        .keyboardShortcut("v", modifiers: [.command, .shift])
    }
}

struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        var types: [UTType] = [.plainText]
        if let md = UTType("net.daringfireball.markdown") {
            types.insert(md, at: 0)
        }
        return types
    }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = String(data: data, encoding: .utf8) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
