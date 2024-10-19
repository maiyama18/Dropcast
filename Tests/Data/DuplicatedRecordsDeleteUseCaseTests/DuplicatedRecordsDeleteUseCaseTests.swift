import CoreData
import Database
import XCTest

@testable import DuplicatedRecordsDeleteUseCase

@MainActor
final class DuplicatedRecordsDeleteUseCaseTests: XCTestCase {
    func test() async throws {
        let context = PersistentProvider.inMemory.viewContext

        // ShowA
        _ = fixtureShow(
            context: context,
            feedURL: URL(string: "https://example.com/showA")!,
            episodes: [
                fixtureEpisode(context: context, id: "A-1"),
                fixtureEpisode(context: context, id: "A-2"),
                fixtureEpisode(context: context, id: "A-2"),
                fixtureEpisode(context: context, id: "A-3"),
                fixtureEpisode(context: context, id: "A-4"),
                fixtureEpisode(context: context, id: "A-4"),
                fixtureEpisode(context: context, id: "A-4"),
            ]
        )

        // ShowB1
        _ = fixtureShow(
            context: context,
            feedURL: URL(string: "https://example.com/showB")!,
            episodes: [
                fixtureEpisode(context: context, id: "B-1"),
                fixtureEpisode(context: context, id: "B-2"),
            ]
        )
        // ShowB2
        _ = fixtureShow(
            context: context,
            feedURL: URL(string: "https://example.com/showB")!,
            episodes: [
                fixtureEpisode(context: context, id: "B-1"),
                fixtureEpisode(context: context, id: "B-2"),
                fixtureEpisode(context: context, id: "B-3"),
            ]
        )
        // ShowB3
        _ = fixtureShow(
            context: context,
            feedURL: URL(string: "https://example.com/showB")!,
            episodes: [
                fixtureEpisode(context: context, id: "B-1"),
            ]
        )

        try context.save()

        let useCase = DuplicatedRecordsDeleteUseCase.live(context: context)
        try useCase.delete()

        let shows = (try context.fetch(ShowRecord.fetchRequest())).sorted(by: { $0.feedURL.absoluteString < $1.feedURL.absoluteString })
        XCTAssertEqual(shows.count, 2)
        XCTAssertEqual(
            shows.map { $0.feedURL.absoluteString },
            ["https://example.com/showA", "https://example.com/showB"]
        )
        XCTAssertEqual(
            shows[0].episodes.map(\.id).sorted(),
            ["A-1", "A-2", "A-3", "A-4"]
        )
        XCTAssertEqual(
            shows[1].episodes.map(\.id).sorted(),
            ["B-1", "B-2", "B-3"]
        )
    }

    private func fixtureShow(
        context: NSManagedObjectContext,
        feedURL: URL,
        episodes: [EpisodeRecord]
    ) -> ShowRecord {
        let show = ShowRecord(
            context: context,
            title: "dummy title",
            description: "dummy description",
            author: "dummy author",
            feedURL: feedURL,
            imageURL: URL(string: "https://example.com/imageURL")!,
            linkURL: URL(string: "https://example.com/linkURL")!
        )
        for episode in episodes {
            show.addToEpisodes_(episode)
        }
        return show
    }

    private func fixtureEpisode(context: NSManagedObjectContext, id: String) -> EpisodeRecord {
        EpisodeRecord(
            context: context,
            id: id,
            title: "dummy title",
            subtitle: "dummy subtitle",
            description: "dummy description",
            duration: 1000,
            soundURL: URL(string: "https://example.com/soundURL")!,
            publishedAt: .now
        )
    }
}
