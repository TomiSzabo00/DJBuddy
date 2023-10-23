//
//  IncreasePriceView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI

struct IncreasePriceView: View {
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
                    viewModel.increasePrice { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(_):
                            // TODO: handle error
                            break
                        }
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
    }
}
