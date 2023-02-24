import AsyncAlgorithms
import Combine
import CustomDump
import XCTest

extension XCTestCase {
    public func XCTAsyncAssertEqual<T: Equatable>(
        _ expression1: @Sendable @escaping @autoclosure () async throws -> T,
        _ expression2: @Sendable @escaping @autoclosure () async throws -> T,
        timeout: Duration = .milliseconds(500),
        _ message: @Sendable @escaping @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await Task.sleep(for: timeout)
                XCTFail("timeout", file: file, line: line)
            }
            group.addTask {
                let value1 = try await expression1()
                let value2 = try await expression2()
                XCTAssertNoDifference(value1, value2, message(), file: file, line: line)
            }

            _ = try await group.next()!
            group.cancelAll()
        }
    }

    public func XCTAssertReceive<E: Equatable>(
        from sequence: AsyncChannel<E>,
        _ expectedValue: @Sendable @escaping @autoclosure () -> E,
        timeout: Duration = .milliseconds(200),
        _ message: @Sendable @escaping @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await Task.sleep(for: timeout)
                XCTFail("timeout occurred before value received", file: file, line: line)
            }
            group.addTask {
                var iterator = sequence.makeAsyncIterator()
                let actual = await iterator.next()
                let expected = expectedValue()
                XCTAssertNoDifference(actual, expected, message(), file: file, line: line)
            }

            _ = try await group.next()!
            group.cancelAll()
        }
    }

    public func XCTAssertNoReceive<E>(
        from sequence: AsyncChannel<E>,
        timeout: Duration = .milliseconds(500),
        _ message: @Sendable @escaping @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await Task.sleep(for: timeout)
            }
            group.addTask {
                var iterator = sequence.makeAsyncIterator()
                if let value = await iterator.next() {
                    XCTFail("value unexpectedly received: \(String(describing: value))", file: file, line: line)
                }
            }

            _ = try await group.next()!
            group.cancelAll()
        }
    }

    public func XCTAssertReceive<E: Equatable, P: Publisher<E, Never>>(
        from publisher: P,
        _ expectedValue: @Sendable @escaping @autoclosure () -> E,
        timeout: TimeInterval = 0.2,
        _ message: @Sendable @escaping @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let expectation = expectation(description: "value should be received")
        var actuals: [E] = []
        let cancellable = publisher
            .sink { value in
                actuals.append(value)
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: timeout)
        XCTAssertNoDifference(actuals.first, expectedValue(), message(), file: file, line: line)
        _ = cancellable
    }

    public func XCTAssertReceive<E: Equatable, P: Publisher<E, Never>>(
        from publisher: P,
        _ expectedValue: @Sendable @escaping @autoclosure () -> E,
        operation: @Sendable () async throws -> Void,
        timeout: TimeInterval = 0.2,
        _ message: @Sendable @escaping @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) async rethrows {
        let expectation = expectation(description: "value should be received")
        var actuals: [E] = []
        let cancellable = publisher
            .sink { value in
                actuals.append(value)
                expectation.fulfill()
            }

        try await operation()

        wait(for: [expectation], timeout: timeout)
        XCTAssertNoDifference(actuals.first, expectedValue(), message(), file: file, line: line)
        _ = cancellable
    }
}
