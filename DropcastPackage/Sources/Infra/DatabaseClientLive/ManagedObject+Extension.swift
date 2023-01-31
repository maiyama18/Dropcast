import CoreData
import Entity

extension ShowRecord {
    convenience init(context: NSManagedObjectContext, show: Show) {
        self.init(context: context)

        title = show.title
        showDescription = show.description
        author = show.author
        feedURL = show.feedURL
        imageURL = show.imageURL
        linkURL = show.linkURL
    }

    func toShow() -> Show? {
        guard let title,
              let feedURL,
              let imageURL else { return nil }

        return Show(
            title: title,
            description: showDescription,
            author: author,
            feedURL: feedURL,
            imageURL: imageURL,
            linkURL: linkURL,
            // FIXME: Fill episodes
            episodes: []
        )
    }
}
