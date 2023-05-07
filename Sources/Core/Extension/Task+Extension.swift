import Combine

extension Task {
    public func store(in set: inout Set<AnyCancellable>) {
        set.insert(.init { cancel() })
    }
}
