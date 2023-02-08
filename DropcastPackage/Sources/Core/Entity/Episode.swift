import Foundation

public struct Episode: Sendable, Identifiable, Equatable {
    public var guid: String
    public var title: String
    public var subtitle: String?
    public var description: String?
    public var duration: TimeInterval
    public var soundURL: URL
    public var publishedAt: Date

    public var showFeedURL: URL
    public var showTitle: String

    public var id: String { guid }

    public init(
        guid: String,
        title: String,
        subtitle: String?,
        description: String?,
        duration: TimeInterval,
        soundURL: URL,
        publishedAt: Date,
        showFeedURL: URL,
        showTitle: String
    ) {
        self.guid = guid
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.duration = duration
        self.soundURL = soundURL
        self.publishedAt = publishedAt

        self.showFeedURL = showFeedURL
        self.showTitle = showTitle
    }
}
