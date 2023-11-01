//
//  SongList.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SongList<Header: View>: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var viewModel: EventControlViewModel

    @ViewBuilder var header: Header

    var body: some View {
        List {
            header
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))

            Section {
                if viewModel.event.requestedSongs.isEmpty {
                    InfoView("There aren't any songs requested. Yet.", type: .info)
                } else {
                    ForEach(Array(viewModel.event.requestedSongs.enumerated()), id: \.offset) { idx, song in
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
            viewModel.sortSongs(&viewModel.event.requestedSongs)
        }
    }

    init(@ViewBuilder header: @escaping () -> Header = { EmptyView() }) {
        self.header = header()
    }
}

#Preview {
    SongList()//SongData.PreviewData])
}
