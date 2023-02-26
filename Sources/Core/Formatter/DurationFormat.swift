import Foundation

public func formatEpisodeDuration(duration: TimeInterval) -> String {
    Duration.seconds(duration).formatted(.time(pattern: duration < 3600 ? .minuteSecond : .hourMinuteSecond))
}

private let hourMinuteSecondFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = [.dropLeading]
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.hour, .minute, .second]
    return formatter
}()

private let minuteSecondFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = [.pad]
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    return formatter
}()
