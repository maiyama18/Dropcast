import Combine
import Dependencies

extension Publisher where Failure == Never {
    public func eraseToStream() -> AsyncStream<Output> {
        self
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .values
            .eraseToStream()
    }
}
