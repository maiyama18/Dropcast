import NukeUI
import SwiftUI

struct ShowHeaderView: View {
    var imageURL: URL
    var title: String
    var author: String?
    var description: String?
    var followed: Bool?
    var isFetchingShow: Bool
    var toggleFollowButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                LazyImage(url: imageURL) { state in
                    if let image = state.image {
                        image
                    } else {
                        Color.secondary
                            .opacity(0.3)
                    }
                }
                .frame(width: 120, height: 120)
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.headline.bold())
                        .lineLimit(3)

                    Spacer(minLength: 0)
                        .frame(height: 2)

                    Group {
                        if let author {
                            Text(author)
                        } else if isFetchingShow {
                            Text("Lorem ipsum")
                                .redacted(reason: .placeholder)
                        }
                    }
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Spacer(minLength: 0)
                        .frame(height: 12)

                    Button {
                        toggleFollowButtonTapped()
                    } label: {
                        if let followed {
                            if followed {
                                Label(L10n.followed, systemImage: "checkmark")
                            } else {
                                Label(L10n.follow, systemImage: "plus")
                            }
                        } else {
                            Label(L10n.loading, systemImage: "circle.dashed")
                        }
                    }
                    .followButtonStyle(followed: followed)
                    .font(.callout.bold())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Maiores et ad ea perspiciatis. Molestias expedita ab autem ad nihil ipsum sed nihil dolorum inventore debitis distinctio velit. Sint magnam dolorum est.")
                .redacted(reason: .placeholder)
                .opacity(isFetchingShow && description == nil ? 1 : 0)
                .overlay(alignment: .topLeading) {
                    if let description {
                        ScrollView {
                            Text(description)
                        }
                    }
                }
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Button {
    @ViewBuilder
    fileprivate func followButtonStyle(followed: Bool?) -> some View {
        if let followed {
            if followed {
                buttonStyle(.borderedProminent)
            } else {
                buttonStyle(.bordered)
            }
        } else {
            buttonStyle(.bordered).disabled(true)
        }
    }
}

import Entity

struct ShowHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            let rebuild = Show.fixtureRebuild
            ShowHeaderView(
                imageURL: rebuild.imageURL,
                title: rebuild.title,
                author: rebuild.author,
                description: rebuild.description,
                followed: false,
                isFetchingShow: false,
                toggleFollowButtonTapped: {}
            )
            .padding()

            Divider()

            let swift = Show.fixtureSwiftBySundell
            ShowHeaderView(
                imageURL: swift.imageURL,
                title: swift.title,
                author: swift.author,
                description: swift.description,
                followed: true,
                isFetchingShow: false,
                toggleFollowButtonTapped: {}
            )
            .padding()

            Divider()

            let program = Show.fixtureプログラム雑談
            ShowHeaderView(
                imageURL: program.imageURL,
                title: program.title,
                author: program.author,
                description: program.description,
                followed: nil,
                isFetchingShow: false,
                toggleFollowButtonTapped: {}
            )
            .padding()
        }
        .tint(.orange)
    }
}
