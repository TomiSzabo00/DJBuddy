//
//  SongList.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SongList: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var viewModel: EventControlViewModel

    @State var songs: [SongData]

    var body: some View {
        List {
            Section {
                if songs.isEmpty {
                    InfoView("There aren't any songs requested. Yet.", type: .info)
                } else {
                    ForEach(Array(songs.enumerated()), id: \.offset) { idx, song in
                        SongRow(song, index: idx)
                            .onTapGesture {
                                navigator.navigate(to: .songDetails(song, viewModel))
                            }
                            .id("\(song.title)\(song.artist)\(song.amount)")
                    }
                }
            } header: {
                Text("Requested songs")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        }
        .preferredColorScheme(.dark)
        .background(Color.asset.background)
        .scrollContentBackground(.hidden)
        .onAppear {
            // Workaround to update list order after price increase
            viewModel.sortSongs(&songs)
        }
    }
}

#Preview {
    SongList(songs: [])//SongData.PreviewData])
}
