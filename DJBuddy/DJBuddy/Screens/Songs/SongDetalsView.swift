//
//  SongDetalsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SongDetalsView: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var user: UserData
    let song: SongData

    var body: some View {
        GeometryReader { geo in
            VStack {
                AsyncImage(url: URL(string: song.albumArtUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geo.size.width)
                } placeholder: {
                    Image("default")
                        .resizable()
                        .scaledToFit()
                        .frame(height: geo.size.width)
                }
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.clear, .asset.background]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                )

                VStack(alignment: .leading, spacing: 0) {
                    Text(song.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(song.artist)
                        .font(.title3)
                        .padding(.vertical, 10)
                    Text("Current price: **\(song.amount.formatted(.currency(code: "USD")))**")
                        .padding([.top], 30)

                    Spacer()

                    if user.type == .dj {
                        Button("Accept") {

                        }
                        .buttonStyle(.largeProminent)
                        .padding(.vertical)

                        Button("Decline") {

                        }
                        .buttonStyle(.largeSecondary)
                    } else {
                        Button("Increase price") {

                        }
                        .buttonStyle(.largeProminent)
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: -30)

            }
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Song", navigator: navigator, leadingButton: .back)
    }
}

#Preview {
    NavigationView {
        SongDetalsView(song: SongData.PreviewData)
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
