import Formatter
import Logger
import OSLog
import SwiftUI

let longestCategoryString: String = LogCategory.allCases.reduce(into: "") { longest, category in
    if category.rawValue.count > longest.count {
        longest = category.rawValue
    }
}

extension LogCategory {
    var color: Color {
        switch self {
        case .app:
            return .indigo
        case .database:
            return .brown
        case .iTunes:
            return .purple
        case .rss:
            return .green
        case .soundFile:
            return .teal
        }
    }
}

extension OSLogEntryLog.Level {
    var color: Color {
        switch self {
        case .undefined:
            return .clear
        case .debug:
            return .clear
        case .info:
            return .clear
        case .notice:
            return .gray
        case .error:
            return .yellow
        case .fault:
            return .red
        @unknown default:
            return .clear
        }
    }
}

struct DebugLogRowView: View {
    var entry: LogEntry

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(entry.level.color)
                .font(.caption2)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(logDateFormatter.string(from: entry.date))

                    Text(entry.category.rawValue)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(entry.category.color)
                        .cornerRadius(4)
                        .bold()
                }

                Text(entry.message)
                    .lineLimit(1)
            }
            .font(.caption.monospaced())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
