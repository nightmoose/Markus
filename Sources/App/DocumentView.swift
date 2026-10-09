import SwiftUI

struct DocumentView: View {
    let document: MarkdownDocument

    var body: some View {
        MarkdownView(text: document.text)
            .background(Color(nsColor: .textBackgroundColor))
            .frame(minWidth: 640, minHeight: 480)
    }
}
