//
//  SimpleSongRow.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 22/10/2023.
//

import SwiftUI

struct SimpleSongRow: View {
    let song: SongData
    let height = 66.0
    var textColor: Color = .black

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: song.albumArtUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
            } placeholder: {
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .frame(height: height)
            }

            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(song.artist)
                    .font(.subheadline)
            }
            .padding(.vertical)
        }
        .foregroundStyle(textColor)
    }
}

#Preview {
    SimpleSongRow(song: SongData.PreviewData)
}
