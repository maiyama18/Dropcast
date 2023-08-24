import Database
import SwiftUI

@MainActor
public struct EpisodeDetailScreen: View {
    private let episode: EpisodeRecord
    
    public init(episode: EpisodeRecord) {
        self.episode = episode
    }
    
    public var body: some View {
        Text(episode.title)
    }
}
