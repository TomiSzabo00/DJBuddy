//
//  SongSelectionView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 22/10/2023.
//

import SwiftUI
import MusicKit

struct SongSelectionView: View {
    @StateObject var viewModel = SongSelectionViewModel()
    @FocusState private var isFocusedTextField: Bool
    @Binding var isShowing: Bool

    var theme: SongTheme? = nil
    let selectAction: (SongData) -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Search for songs...", text: $viewModel.searchableText)
                    .padding()
                    .autocorrectionDisabled()
                    .focused($isFocusedTextField)
                    .font(.title)
                    .onReceive(
                        viewModel.$searchableText.debounce(
                            for: .seconds(0.5),
                            scheduler: DispatchQueue.main
                        )
                    ) {
                        if $0.count > 3 {
                            viewModel.searchSong($0, theme: theme)
                        }
                        if $0.isEmpty {
                            viewModel.searchResults.removeAll()
                        }
                    }
                    .background(Color.init(uiColor: .systemBackground))
                    .overlay {
                        ClearButton(text: $viewModel.searchableText)
                            .padding(.trailing)
                            .padding(.top, 8)
                    }
                    .onAppear {
                        isFocusedTextField = true
                    }

                List(viewModel.searchResults) { song in
                    SimpleSongRow(song: song, textColor: .white)
                        .onTapGesture {
                            selectAction(song)
                            isShowing = false
                        }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .loadingOverlay(isLoading: $viewModel.isSearching)
            }
            .navBarWithTitle(title: "Select music", leadingButton: .close($isShowing))
            .backgroundColor(.asset.background)
        }
    }
}

#Preview {
    SongSelectionView(isShowing: .constant(true)) { _ in }
}
