//
//  SongSelectionFromPlaylistView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 17/03/2024.
//

import SwiftUI

struct SongSelectionFromPlaylistView: View {
    @Binding var isShowing: Bool
    @State var playlist: Playlist
    let selectAction: (SongData) -> Void
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    @State private var searchText = ""

    var filteredSongs: [SongData] {
        if searchText.isEmpty {
            return playlist.songs
        }

        return playlist.songs.filter({ $0.title.uppercased().contains(searchText.uppercased()) ||
            $0.artist.uppercased().contains(searchText.uppercased()) })
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollProxy in
                    ZStack {
                        List {
                            if !filteredSongs.filter({ !alphabet.contains(String($0.title.uppercased().prefix(1))) }).isEmpty {
                                Section(header: Text("&").id("&")) {
                                    ForEach(filteredSongs.filter({ !alphabet.contains(String($0.title.uppercased().prefix(1))) })) { song in
                                        SimpleSongRow(song: song, height: 80)
                                            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.white)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .onTapGesture {
                                                selectAction(song)
                                                isShowing = false
                                            }
                                    }
                                }
                                .listStyle(.plain)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 14))
                            }
                            ForEach(alphabet.filter({ letter in filteredSongs.contains(where: { $0.title.uppercased().prefix(1) == letter }) }), id: \.self) { letter in
                                Section(header: Text(letter).id(letter)) {
                                    ForEach(filteredSongs.filter({ $0.title.uppercased().prefix(1) == letter})) { song in
                                        SimpleSongRow(song: song, height: 80)
                                            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.white)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .onTapGesture {
                                                selectAction(song)
                                                isShowing = false
                                            }
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 14))
                        }
                        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                        .preferredColorScheme(.dark)
                        .scrollContentBackground(.hidden)

                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        scrollProxy.scrollTo("&")
                                    }
                                }, label: {
                                    Text("&")
                                        .font(.system(size: 14))
                                        .padding(.trailing, 7)
                                })
                                .tint(.red)
                                .disabled(filteredSongs.filter({ !alphabet.contains(String($0.title.uppercased().prefix(1))) }).isEmpty)
                            }

                            ForEach(alphabet, id: \.self) { letter in
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            scrollProxy.scrollTo(letter)
                                        }
                                    }, label: {
                                        Text(letter)
                                            .font(.system(size: 14))
                                            .padding(.trailing, 7)
                                    })
                                    .tint(.red)
                                    .disabled(!filteredSongs.contains(where: { $0.title.uppercased().prefix(1) == letter }))
                                }
                            }
                        }
                        .padding(.trailing, 5)
                    }
                }
                .scrollDismissesKeyboard(.automatic)
            }
            .backgroundColor(.asset.background)
            .navBarWithTitle(title: "Songs in the playlist", leadingButton: .close($isShowing))
        }
    }
}

#Preview {
    NavigationView {
        SongSelectionFromPlaylistView(isShowing: .constant(true), playlist: Playlist.PreviewData) { _ in }
    }
}
