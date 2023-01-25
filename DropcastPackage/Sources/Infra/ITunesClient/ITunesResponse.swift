import Entity
import Foundation

struct SearchShowsResponse: Decodable {
    var resultCount: Int
    var results: [ShowResponse]
}

struct ShowResponse: Decodable {
    var trackID: Int
    var artistName: String
    var trackName: String
    var primaryGenreName: String
    var feedURL: String
    var trackViewURL: String
    var artworkURL100: String
    var artworkURL600: String

    enum CodingKeys: String, CodingKey {
        case trackID = "trackId"
        case artistName
        case trackName
        case primaryGenreName
        case feedURL = "feedUrl"
        case trackViewURL = "trackViewUrl"
        case artworkURL100 = "artworkUrl100"
        case artworkURL600 = "artworkUrl600"
    }

    func toShow() -> Show? {
        guard let feedURL = URL(string: feedURL),
              let trackViewURL = URL(string: trackViewURL),
              let artworkURL600 = URL(string: artworkURL600),
              let artworkURL100 = URL(string: artworkURL100) else {
            return nil
        }

        return Show(
            id: trackID,
            artistName: artistName,
            showName: trackName,
            genreName: primaryGenreName,
            feedURL: feedURL,
            storeURL: trackViewURL,
            artworkURL: artworkURL600,
            artworkLowQualityURL: artworkURL100
        )
    }
}
