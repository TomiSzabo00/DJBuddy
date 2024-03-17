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

            HStack {
                Text("^[\(playlist.songs.count) song](inflect: true)")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)

                if !playlist.hasEnoughSongs {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                }
            }
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
