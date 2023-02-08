import Foundation

public struct Episode: Sendable, Equatable {
    public var guid: String
    public var title: String
    public var subtitle: String?
    public var description: String?
    public var duration: TimeInterval
    public var soundURL: URL

    public var showFeedURL: URL
    public var showTitle: String

    public init(
        guid: String,
        title: String,
        subtitle: String?,
        description: String?,
        duration: TimeInterval,
        soundURL: URL,
        showFeedURL: URL,
        showTitle: String
    ) {
        self.guid = guid
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.duration = duration
        self.soundURL = soundURL

        self.showFeedURL = showFeedURL
        self.showTitle = showTitle
    }
}
