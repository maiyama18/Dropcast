import Foundation
import XCTest

@testable import Formatter

final class DateFormatterTests: XCTestCase {
    func test_rssDateFormatter() {
        XCTAssertEqual(
            rssDateFormatter.date(from: "Tue, 03 Jan 2023 20:00:00 -0800"),
            Date(timeIntervalSince1970: 1672804800)
        )

        XCTAssertEqual(
            rssDateFormatter.date(from: "Tue, 24 Jan 2023 05:20:00 +0000"),
            Date(timeIntervalSince1970: 1674537600)
        )

        XCTAssertEqual(
            rssDateFormatter.date(from: "Wed, 18 Jan 2023 11:00:20 GMT"),
            Date(timeIntervalSince1970: 1674039620)
        )
    }
}
