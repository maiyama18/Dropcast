import SwiftUI

struct ShowHeaderView: View {
    var imageURL: URL
    var title: String
    var author: String?
    var description: String?
    var followed: Bool?
    var requestInFlight: Bool
    var toggleFollowButtonTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.secondary
                        .opacity(0.3)
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
                        } else if requestInFlight {
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
                                Label("Followed", systemImage: "checkmark")
                            } else {
                                Text("Follow")
                            }
                        } else {
                            Text("Loading")
                        }
                    }
                    .followButtonStyle(followed: followed)
                    .font(.callout.bold())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if let description {
                    Text(description)
                } else if requestInFlight {
                    Text("Maiores et ad ea perspiciatis. Molestias expedita ab autem ad nihil ipsum sed nihil dolorum inventore debitis distinctio velit. Sint magnam dolorum est.")
                        .redacted(reason: .placeholder)
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
                requestInFlight: false,
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
                requestInFlight: false,
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
                requestInFlight: false,
                toggleFollowButtonTapped: {}
            )
            .padding()
        }
        .tint(.orange)
    }
}
