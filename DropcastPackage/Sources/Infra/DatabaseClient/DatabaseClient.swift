import Dependencies
import Entity

public struct DatabaseClient: Sendable {
    public var followShow: @Sendable (Show) throws -> Void
    public var fetchFollowingShows: @Sendable () throws -> [Show]

    public init(
        followShow: @escaping @Sendable (Show) throws -> Void,
        fetchFollowingShows: @escaping @Sendable () throws -> [Show]
    ) {
        self.followShow = followShow
        self.fetchFollowingShows = fetchFollowingShows
    }
}

extension DatabaseClient: TestDependencyKey {
    public static let testValue: DatabaseClient = DatabaseClient(
        followShow: unimplemented(),
        fetchFollowingShows: unimplemented()
    )
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
