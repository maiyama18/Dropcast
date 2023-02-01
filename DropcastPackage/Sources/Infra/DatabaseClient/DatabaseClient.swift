import AsyncAlgorithms
import Dependencies
import Entity
import Foundation
import IdentifiedCollections

public struct DatabaseClient: Sendable {
    public var fetchShow: @Sendable (URL) throws -> Show?
    public var followShow: @Sendable (Show) throws -> Void
    public var followedShowsStream: @Sendable () -> AsyncChannel<IdentifiedArrayOf<Show>>

    public init(
        fetchShow: @escaping @Sendable (URL) throws -> Show?,
        followShow: @escaping @Sendable (Show) throws -> Void,
        followedShowsStream: @escaping @Sendable () -> AsyncChannel<IdentifiedArrayOf<Show>>
    ) {
        self.fetchShow = fetchShow
        self.followShow = followShow
        self.followedShowsStream = followedShowsStream
    }
}

extension DatabaseClient: TestDependencyKey {
    public static let testValue: DatabaseClient = DatabaseClient(
        fetchShow: unimplemented(),
        followShow: unimplemented(),
        followedShowsStream: unimplemented()
    )
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
