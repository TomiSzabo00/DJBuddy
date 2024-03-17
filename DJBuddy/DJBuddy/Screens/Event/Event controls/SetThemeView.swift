//
//  SetThemeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import SwiftUI

struct SetThemeView: View {
    let playlists: [Playlist]
    let themeSelection: (SongTheme) -> Void
    let playlistSelection: (Playlist) -> Void
    let cancel: () -> Void

    @State private var selectedTheme: SongTheme? = .pop
    @State private var selectedPlaylist: Playlist? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set theme")
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(SongTheme.allCases, id: \.hashValue) { theme in
                        Text(theme.displayName).tag(Optional(theme))
                    }
                }
            } label: {
                pickerLabel(for: selectedTheme)
            }

            Text("or")

            Text("Set playlist")
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Picker("Playlist", selection: $selectedPlaylist) {
                    ForEach(playlists) { playlist in
                        Text(playlist.title).tag(Optional(playlist))
                    }
                }
            } label: {
                pickerLabel(for: selectedPlaylist)
            }

            Spacer()

            if let selectedTheme {
                Button("Set theme") {
                    themeSelection(selectedTheme)
                }
                .buttonStyle(.largeProminent)
            } else if let selectedPlaylist {
                Button("Set playlist") {
                    playlistSelection(selectedPlaylist)
                }
                .buttonStyle(.largeProminent)
            }

            Button("Cancel") {
                cancel()
            }
            .buttonStyle(.largeSecondary)
        }
        .foregroundStyle(.white)
        .padding()
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Theme")
        .onChange(of: selectedTheme) { _, newTheme in
            if newTheme != nil {
                selectedPlaylist = nil
            }
        }
        .onChange(of: selectedPlaylist) { _, newPlaylist in
            if newPlaylist != nil {
                selectedTheme = nil
            }
        }
    }

    @ViewBuilder private func pickerLabel(for theme: SongTheme?) -> some View {
        HStack {
            Text(theme?.displayName ?? "")
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "arrowtriangle.down.fill")
        }
        .padding()
        .foregroundStyle(.gray)
        .backgroundColor(.white)
        .frame(maxHeight: 60)
        .clipShape(.rect(cornerRadius: 12))
    }

    @ViewBuilder private func pickerLabel(for playlist: Playlist?) -> some View {
        HStack {
            Text(playlist?.title ?? "")
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "arrowtriangle.down.fill")
        }
        .padding()
        .foregroundStyle(.gray)
        .backgroundColor(.white)
        .frame(maxHeight: 60)
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    SetThemeView(playlists: [Playlist.PreviewData], themeSelection: { _ in }, playlistSelection: { _ in }, cancel: {})
}
