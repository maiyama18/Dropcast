import CoreData
import Entity

extension ShowRecord {
    convenience init(context: NSManagedObjectContext, show: Show) {
        self.init(context: context)

        title = show.title
        showDescription = show.description
        author = show.author
        imageURL = show.imageURL
        linkURL = show.linkURL
    }

    func toShow() -> Show? {
        guard let title,
              let imageURL else { return nil }

        return Show(
            title: title,
            description: showDescription,
            author: author,
            imageURL: imageURL,
            linkURL: linkURL,
            // FIXME: Fill episodes
            episodes: []
        )
    }
}
