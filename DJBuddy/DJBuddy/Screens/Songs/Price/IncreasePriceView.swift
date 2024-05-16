//
//  IncreasePriceView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI

struct IncreasePriceView: View {
    @EnvironmentObject private var stateHelper: StateHelper
    @EnvironmentObject var user: UserData

    let song: SongData
    @StateObject var viewModel: EventControlViewModel
    @Binding var isShowing: Bool

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Increase price by")
                PriceSelectionView(amounts: [1, 3, 5], selectedAmount: $viewModel.selectedPrice, amountToNext: viewModel.amountToNextSong)

                if viewModel.shouldSHowPriceWarining {
                    InfoView("This amount won’t change the position of this song in the list. If you want to move it up, choose a bigger amount.", type: .warning)
                }

                Spacer()

                Button("Increase") {
                    isShowing = false
                    stateHelper.performWithProgress {
                        try await viewModel.increasePrice(by: user)
                    }
                }
                .buttonStyle(.largeProminent)

                Button("Cancel") {
                    isShowing = false
                }
                .buttonStyle(.largeSecondary)
            }
            .padding()
            .navBarWithTitle(title: "Increase price", leadingButton: .close($isShowing))
            .backgroundColor(.asset.background)
        }
    }
}

#Preview {
    NavigationView {
        IncreasePriceView(song: SongData.PreviewData, viewModel: EventControlViewModel(event: EventData.PreviewData), isShowing: .constant(true))
            .environmentObject(UserData.EmptyUser)
    }
}
