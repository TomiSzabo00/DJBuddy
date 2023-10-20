//
//  SongRow.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SongRow: View {
    let song: SongData
    let index: Int
    let height: CGFloat

    var body: some View {
        HStack(spacing: 20) {
            Text("\(index + 1).")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

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
                        .font(.title)
                        .fontWeight(.semibold)
                    Text(song.artist)
                        .font(.subheadline)
                }
                .padding(.vertical)

                Spacer()

                Text("\(song.amount.formatted(.currency(code: "USD")))")
                    .padding()
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, maxHeight: height, alignment: .leading)
            .background(.white)
            .clipShape(.rect(cornerRadius: 12))

        }
    }

    init(_ song: SongData, index: Int, height: CGFloat = 70) {
        self.song = song
        self.index = index
        self.height = height
    }
}

#Preview {
    SongRow(SongData.PreviewData, index: 0)
        .padding()
        .backgroundColor(.asset.background)
}
