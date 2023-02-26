import Foundation
import XCTest

@testable import Formatter

final class DurationFormatTests: XCTestCase {
    func test_formatEpisodeDuration() {
        XCTAssertEqual(
            formatEpisodeDuration(duration: 1),
            "0:01"
        )

        XCTAssertEqual(
            formatEpisodeDuration(duration: 60),
            "1:00"
        )

        XCTAssertEqual(
            formatEpisodeDuration(duration: 66),
            "1:06"
        )

        XCTAssertEqual(
            formatEpisodeDuration(duration: 3600),
            "1:00:00"
        )

        XCTAssertEqual(
            formatEpisodeDuration(duration: 5025),
            "1:23:45"
        )
    }
}
