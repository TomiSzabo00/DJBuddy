//
//  RequestSongView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct RequestSongView: View {
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var viewModel: EventControlViewModel

    @State var songText = ""
    @State var didAgree = false
    @State var selectedPrice: Double = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let theme = viewModel.event.theme {
                InfoView("The DJ has set the theme to \(theme.displayName.uppercased()) for this event. You can only request songs from this category at the moment.", type: .info)
            }

            Text("Choose a song:")
            PlaceholderTextField(placeholder: "Artist or title", text: $songText)

            Text("Set a price")
            PriceSelectionView(amounts: [1, 3, 5], selectedAmount: $selectedPrice)

            Button("I agree to the [Terms and Conditions](https://en.wikipedia.org/wiki/Terms_of_service) and understand that by pressing this button i will be charged.") {

            }
            .buttonStyle(.checkmark(isOn: $didAgree))
        }
        .foregroundStyle(.white)
        .padding()
        .backgroundColor(.asset.background)
    }

    @ViewBuilder private func agreePrivacyPolicy(_ checkbox: Binding<Bool>) -> some View {
        HStack {
            Toggle("Title", isOn: checkbox)
        }
    }
}

#Preview {
    RequestSongView(viewModel: EventControlViewModel(event: EventData.PreviewData))
        .environmentObject(Navigator())
}
