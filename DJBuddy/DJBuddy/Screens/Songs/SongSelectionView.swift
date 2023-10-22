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

    var body: some View {
        NavigationView {
            VStack {
                Button("Genres") {
                    viewModel.getAllGenres()
                }

                Button("Songs") {
                    viewModel.searchMusic()
                }
            }
            .navBarWithTitle(title: "Select music")
            .backgroundColor(.asset.background)
        }
    }
}

#Preview {
    SongSelectionView()
}
