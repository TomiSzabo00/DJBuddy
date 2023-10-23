//
//  IncreasePriceView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI

struct IncreasePriceView: View {
    @StateObject var viewModel: EventControlViewModel
    @Binding var isShowing: Bool

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Increase price by")
                PriceSelectionView(amounts: [1, 3, 5], selectedAmount: $viewModel.selectedPrice)
            }
            .padding()
            .navBarWithTitle(title: "Inc. price", leadingButton: .close($isShowing))
            .backgroundColor(.asset.background)
        }
    }
}

#Preview {
    NavigationView {
        IncreasePriceView(viewModel: EventControlViewModel(event: EventData.PreviewData), isShowing: .constant(true))
    }
}
