import SwiftUI

public struct HTMLView: UIViewRepresentable {
    private let htmlBodyString: String
    private let contentBottomInset: Double
    
    public init(htmlBodyString: String, contentBottomInset: Double) {
        self.htmlBodyString = htmlBodyString
        self.contentBottomInset = contentBottomInset
    }
    
    public func makeUIView(context: Context) -> UITextView {
        let uiTextView = UITextView()
        
        uiTextView.backgroundColor = .clear
        uiTextView.isEditable = false
        
        uiTextView.isScrollEnabled = true
        uiTextView.showsVerticalScrollIndicator = false
        uiTextView.setContentHuggingPriority(.defaultLow, for: .vertical)
        uiTextView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        uiTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return uiTextView
    }
    
    public func updateUIView(_ uiTextView: UITextView, context: Context) {
        uiTextView.contentInset.bottom = contentBottomInset
        
        do {
            let htmlString = html(
                bodyString: htmlBodyString,
                labelColor: UIColor.label.resolvedColor(with: uiTextView.traitCollection)
            )
            uiTextView.attributedText = try NSAttributedString(
                data: Data(htmlString.utf8),
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ],
                documentAttributes: nil
            )
        } catch {
            uiTextView.attributedText = NSAttributedString(string: htmlBodyString)
        }
    }
    
    private func html(bodyString: String, labelColor: UIColor) -> String {
        return """
        <!doctype html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <style type="text/css">
                body {
                    font: -apple-system-body;
                    font-size: \(Int(UIFont.preferredFont(forTextStyle: .body).pointSize))px;
                    color: \(hexString(of: labelColor));
                }
            </style>
        </head>
        <body>
            \(bodyString)
        </body>
        </html>
        """
    }
    
    private func hexString(of uiColor: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255)),
            lroundf(Float(alpha * 255))
        )
    }
}
