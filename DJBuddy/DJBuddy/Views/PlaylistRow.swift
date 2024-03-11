//
//  PlaylistRow.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 07/03/2024.
//

import SwiftUI

struct PlaylistRow: View {
    @State var playlist: Playlist

    var body: some View {
        VStack(alignment: .leading) {
            Text(playlist.title)
                .foregroundStyle(Color.black)
                .textCase(.uppercase)
                .fontWeight(.heavy)
                .font(.title3)

            Text("\(playlist.songs.count) songs")
                .font(.subheadline)
                .foregroundStyle(Color.gray)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack {
        PlaylistRow(playlist: Playlist(id: 0, title: "Test"))
    }
    .backgroundColor(.background)
}
