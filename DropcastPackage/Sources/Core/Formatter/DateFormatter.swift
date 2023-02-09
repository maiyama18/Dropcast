import Foundation

/// DateFormatter for RFC-2822 format that used in pubDate property of RSS feed
public let rssDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()
